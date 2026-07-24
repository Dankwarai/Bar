<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager', 'bartender');
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

// AJAX: bump a single order_item status
if (isset($_GET['ajax']) && $_GET['ajax'] === 'bump' && isset($_POST['item_id'])) {
    $id = (int)$_POST['item_id'];
    $flow = ['ordered' => 'preparing', 'preparing' => 'ready', 'ready' => 'served'];
    $stmt = db()->prepare("SELECT status FROM bar_order_items WHERE id = ?");
    $stmt->execute([$id]);
    $current = $stmt->fetchColumn();
    if ($current && isset($flow[$current])) {
        $next = $flow[$current];
        db()->prepare("UPDATE bar_order_items SET status = ? WHERE id = ?")->execute([$next, $id]);
        // If all items in the order are ready/served, update order status
        $orderId = db()->prepare("SELECT order_id FROM bar_order_items WHERE id = ?");
        $orderId->execute([$id]);
        $oid = $orderId->fetchColumn();
        if ($oid) {
            $remaining = db()->prepare("SELECT COUNT(*) FROM bar_order_items WHERE order_id = ? AND status NOT IN ('ready','served','cancelled')");
            $remaining->execute([$oid]);
            if ((int)$remaining->fetchColumn() === 0) {
                db()->prepare("UPDATE bar_orders SET status = 'ready' WHERE id = ? AND status = 'accepted'")->execute([$oid]);
            }
        }
        echo json_encode(['ok' => true, 'next' => $next]);
    } else {
        echo json_encode(['ok' => false]);
    }
    exit;
}

// AJAX: bump entire order status (accepted→ready→served)
if (isset($_GET['ajax']) && $_GET['ajax'] === 'bump_order' && isset($_POST['order_id'])) {
    $oid = (int)$_POST['order_id'];
    $flow = ['accepted' => 'ready', 'ready' => 'served'];
    $stmt = db()->prepare("SELECT status FROM bar_orders WHERE id = ?");
    $stmt->execute([$oid]);
    $current = $stmt->fetchColumn();
    if ($current && isset($flow[$current])) {
        $next = $flow[$current];
        db()->prepare("UPDATE bar_orders SET status = ? WHERE id = ?")->execute([$next, $oid]);
        if ($next === 'served') {
            db()->prepare("UPDATE bar_order_items SET status = 'served' WHERE order_id = ? AND status NOT IN ('cancelled')")->execute([$oid]);
        }
        echo json_encode(['ok' => true, 'next' => $next]);
    } else {
        echo json_encode(['ok' => false]);
    }
    exit;
}

// AJAX: refresh kitchen data
if (isset($_GET['ajax']) && $_GET['ajax'] === 'refresh') {
    // Re-read active orders
    $orders = fetchKitchenOrders();
    echo json_encode(['orders' => $orders, 'time' => date('H:i:s')]);
    exit;
}

function fetchKitchenOrders(): array {
    $stmt = db()->prepare("
        SELECT o.id, o.status AS order_status, o.source, o.created_at,
               t.number AS table_number
        FROM bar_orders o
        JOIN bar_tables t ON t.id = o.table_id
        WHERE o.status IN ('accepted', 'ready')
        ORDER BY o.created_at ASC
    ");
    $stmt->execute();
    $orders = $stmt->fetchAll();

    foreach ($orders as &$order) {
        $stmt2 = db()->prepare("
            SELECT oi.id, oi.quantity, oi.status, mi.name
            FROM bar_order_items oi
            JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
            WHERE oi.order_id = ? AND oi.status != 'cancelled'
            ORDER BY oi.id
        ");
        $stmt2->execute([$order['id']]);
        $order['items'] = $stmt2->fetchAll();
    }
    return $orders;
}

$orders = fetchKitchenOrders();

$statusColor = [
    'ordered'   => ['bg' => 'bg-yellow-100', 'text' => 'text-yellow-800', 'border' => 'border-yellow-300', 'label' => 'Ordered'],
    'preparing' => ['bg' => 'bg-blue-100',   'text' => 'text-blue-800',   'border' => 'border-blue-300',   'label' => 'Preparing'],
    'ready'     => ['bg' => 'bg-green-100',  'text' => 'text-green-800',  'border' => 'border-green-300',  'label' => 'Ready'],
    'served'    => ['bg' => 'bg-gray-100',   'text' => 'text-gray-500',   'border' => 'border-gray-200',   'label' => 'Served'],
];
$orderBorderColor = ['accepted' => 'border-amber-400', 'ready' => 'border-green-500'];
$nextLabel = ['ordered' => '▶ Preparing', 'preparing' => '✓ Ready', 'ready' => '🚀 Served'];
$orderNextLabel = ['accepted' => 'Mark All Ready', 'ready' => 'Mark Served'];
?>
<div class="p-4 md:p-6" id="kitchenRoot">
    <div class="page-header">
        <div class="flex items-center gap-3">
            <h2 class="page-title"><i class="ri-fire-line text-orange-500 mr-1"></i> Kitchen Display</h2>
            <span id="orderCount" class="badge badge-pending text-xs"><?= count($orders) ?> active</span>
        </div>
        <div class="flex items-center gap-3">
            <span class="text-xs text-gray-400">Auto-refreshes every 10s &nbsp;|&nbsp; Last: <span id="lastRefresh"><?= date('H:i:s') ?></span></span>
            <button onclick="refreshKitchen()" class="btn btn-outline btn-sm"><i class="ri-refresh-line"></i> Refresh</button>
            <button id="muteBtn" onclick="toggleMute()" class="btn btn-outline btn-sm" title="Toggle sound alert"><i class="ri-volume-up-line"></i></button>
        </div>
    </div>

    <!-- Legend -->
    <div class="flex flex-wrap gap-2 mb-4">
        <?php foreach ($statusColor as $key => $s): ?>
        <span class="badge <?= $s['bg'] ?> <?= $s['text'] ?> border <?= $s['border'] ?>"><?= $s['label'] ?></span>
        <?php endforeach; ?>
        <span class="text-xs text-gray-400 self-center ml-2">Click an item to advance its status</span>
    </div>

    <div id="kitchenGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <?php if (empty($orders)): ?>
        <div class="col-span-full empty-state" id="emptyState">
            <i class="ri-restaurant-line"></i>
            <p class="font-medium text-gray-700">All caught up!</p>
            <p class="text-sm mt-1">No active orders in the kitchen.</p>
        </div>
        <?php else: ?>
        <?php foreach ($orders as $order):
            $borderClass = $orderBorderColor[$order['order_status']] ?? 'border-gray-300';
            $waitMins = round((time() - strtotime($order['created_at'])) / 60);
            $urgentClass = $waitMins >= 15 ? 'bg-red-50' : ($waitMins >= 8 ? 'bg-amber-50' : 'bg-white');
        ?>
        <div class="order-card card border-l-4 <?= $borderClass ?> <?= $urgentClass ?> p-0 overflow-hidden" data-order-id="<?= $order['id'] ?>">
            <!-- Card header -->
            <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100">
                <div class="flex items-center gap-2">
                    <span class="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 font-bold text-sm">
                        <?= $order['table_number'] ?>
                    </span>
                    <div>
                        <p class="font-bold text-sm">Table <?= $order['table_number'] ?></p>
                        <p class="text-xs text-gray-400">#<?= $order['id'] ?> &bull; <?= $order['source'] ?></p>
                    </div>
                </div>
                <div class="text-right">
                    <span class="text-xs font-medium <?= $waitMins >= 15 ? 'text-red-600' : ($waitMins >= 8 ? 'text-amber-600' : 'text-gray-400') ?>">
                        <?= $waitMins ?>m ago
                    </span>
                    <p class="text-xs text-gray-400"><?= date('H:i', strtotime($order['created_at'])) ?></p>
                </div>
            </div>

            <!-- Items -->
            <div class="px-4 py-3 space-y-2">
                <?php foreach ($order['items'] as $item):
                    $s = $statusColor[$item['status']] ?? $statusColor['ordered'];
                    $hasNext = isset($nextLabel[$item['status']]);
                ?>
                <div class="flex items-center justify-between gap-2 order-item" data-item-id="<?= $item['id'] ?>">
                    <div class="flex items-center gap-2 min-w-0">
                        <span class="text-sm font-semibold text-gray-600 w-5 text-center flex-shrink-0"><?= $item['quantity'] ?>×</span>
                        <span class="text-sm truncate"><?= e($item['name']) ?></span>
                    </div>
                    <?php if ($hasNext): ?>
                    <button
                        onclick="bumpItem(<?= $item['id'] ?>, this)"
                        class="flex-shrink-0 text-xs px-2 py-1 rounded-full border font-medium transition cursor-pointer <?= $s['bg'] ?> <?= $s['text'] ?> <?= $s['border'] ?> hover:opacity-80 active:scale-95">
                        <?= $nextLabel[$item['status']] ?>
                    </button>
                    <?php else: ?>
                    <span class="flex-shrink-0 text-xs px-2 py-1 rounded-full border <?= $s['bg'] ?> <?= $s['text'] ?> <?= $s['border'] ?>"><?= $s['label'] ?></span>
                    <?php endif; ?>
                </div>
                <?php endforeach; ?>
            </div>

            <!-- Footer action -->
            <?php if (isset($orderNextLabel[$order['order_status']])): ?>
            <div class="px-4 py-3 border-t border-gray-100 bg-gray-50">
                <button
                    onclick="bumpOrder(<?= $order['id'] ?>, this)"
                    class="btn btn-sm w-full <?= $order['order_status'] === 'ready' ? 'btn-success' : 'btn-accent' ?>">
                    <?= $orderNextLabel[$order['order_status']] ?>
                </button>
            </div>
            <?php endif; ?>
        </div>
        <?php endforeach; ?>
        <?php endif; ?>
    </div>
</div>

<script>
var KITCHEN_BUMP_URL   = '/bar/pages/kitchen.php?ajax=bump';
var KITCHEN_ORDER_URL  = '/bar/pages/kitchen.php?ajax=bump_order';
var KITCHEN_REFRESH    = '/bar/pages/kitchen.php?ajax=refresh';
var refreshTimer;
var lastKnownOrderIds  = <?= json_encode(array_column($orders, 'id')) ?>;
var audioCtx = null;

// Synthesise a short "ding" tone — no audio file needed
function playDing() {
    try {
        if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        var now = audioCtx.currentTime;
        [0, 0.18, 0.36].forEach(function(offset) {
            var osc  = audioCtx.createOscillator();
            var gain = audioCtx.createGain();
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(880, now + offset);
            gain.gain.setValueAtTime(0.4, now + offset);
            gain.gain.exponentialRampToValueAtTime(0.001, now + offset + 0.3);
            osc.start(now + offset);
            osc.stop(now + offset + 0.35);
        });
    } catch(e) { /* AudioContext not available */ }
}

function bumpItem(itemId, btn) {
    btn.disabled = true;
    btn.textContent = '...';
    fetch(KITCHEN_BUMP_URL, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'item_id=' + itemId
    })
    .then(function(r){ return r.json(); })
    .then(function(data) {
        if (data.ok) {
            refreshKitchen();
        } else {
            btn.disabled = false;
            btn.textContent = 'Error';
        }
    })
    .catch(function(){ btn.disabled = false; btn.textContent = 'Retry'; });
}

function bumpOrder(orderId, btn) {
    btn.disabled = true;
    btn.textContent = '...';
    fetch(KITCHEN_ORDER_URL, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'order_id=' + orderId
    })
    .then(function(r){ return r.json(); })
    .then(function(data) {
        if (data.ok) {
            refreshKitchen();
        } else {
            btn.disabled = false;
            btn.textContent = 'Error';
        }
    })
    .catch(function(){ btn.disabled = false; btn.textContent = 'Retry'; });
}

function refreshKitchen() {
    fetch(KITCHEN_REFRESH)
    .then(function(r){ return r.json(); })
    .then(function(data) {
        document.getElementById('lastRefresh').textContent = data.time;
        document.getElementById('orderCount').textContent = data.orders.length + ' active';

        // Check for new orders and play alert
        var newIds = data.orders.map(function(o) { return o.id; });
        var hasNew = newIds.some(function(id) { return lastKnownOrderIds.indexOf(id) === -1; });
        if (hasNew) playDing();
        lastKnownOrderIds = newIds;

        rebuildGrid(data.orders);
    })
    .catch(function(){ /* silent fail, will retry */ });
}

function esc(str) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(String(str)));
    return d.innerHTML;
}

function rebuildGrid(orders) {
    var grid = document.getElementById('kitchenGrid');
    if (!orders.length) {
        grid.innerHTML = '<div class="col-span-full empty-state"><i class="ri-restaurant-line" style="font-size:3rem;opacity:.3;display:block;margin-bottom:.75rem"></i><p class="font-medium text-gray-700">All caught up!</p><p class="text-sm mt-1">No active orders in the kitchen.</p></div>';
        return;
    }

    var statusColor = {
        ordered:   { bg:'bg-yellow-100', text:'text-yellow-800', border:'border-yellow-300', label:'Ordered' },
        preparing: { bg:'bg-blue-100',   text:'text-blue-800',   border:'border-blue-300',   label:'Preparing' },
        ready:     { bg:'bg-green-100',  text:'text-green-800',  border:'border-green-300',  label:'Ready' },
        served:    { bg:'bg-gray-100',   text:'text-gray-500',   border:'border-gray-200',   label:'Served' }
    };
    var nextLabel = { ordered:'▶ Preparing', preparing:'✓ Ready', ready:'🚀 Served' };
    var orderNextLabel = { accepted:'Mark All Ready', ready:'Mark Served' };
    var orderBorderColor = { accepted:'border-amber-400', ready:'border-green-500' };
    var orderBtnClass = { accepted:'btn-accent', ready:'btn-success' };

    var html = '';
    orders.forEach(function(order) {
        var waitMins = Math.round((Date.now()/1000 - new Date(order.created_at).getTime()/1000) / 60);
        var urgentClass = waitMins >= 15 ? 'bg-red-50' : (waitMins >= 8 ? 'bg-amber-50' : 'bg-white');
        var borderClass = orderBorderColor[order.order_status] || 'border-gray-300';
        var timeStr = order.created_at.substring(11, 16);

        var itemsHtml = '';
        order.items.forEach(function(item) {
            var s = statusColor[item.status] || statusColor.ordered;
            var hasNext = nextLabel[item.status];
            var btn = hasNext
                ? '<button onclick="bumpItem(' + item.id + ',this)" class="flex-shrink-0 text-xs px-2 py-1 rounded-full border font-medium transition ' + s.bg + ' ' + s.text + ' ' + s.border + ' hover:opacity-80 active:scale-95">' + hasNext + '</button>'
                : '<span class="flex-shrink-0 text-xs px-2 py-1 rounded-full border ' + s.bg + ' ' + s.text + ' ' + s.border + '">' + s.label + '</span>';
            itemsHtml += '<div class="flex items-center justify-between gap-2">'
                + '<div class="flex items-center gap-2 min-w-0">'
                + '<span class="text-sm font-semibold text-gray-600 w-5 text-center flex-shrink-0">' + item.quantity + '×</span>'
                + '<span class="text-sm truncate">' + esc(item.name) + '</span>'
                + '</div>' + btn + '</div>';
        });

        var footerHtml = '';
        if (orderNextLabel[order.order_status]) {
            footerHtml = '<div class="px-4 py-3 border-t border-gray-100 bg-gray-50">'
                + '<button onclick="bumpOrder(' + order.id + ',this)" class="btn btn-sm w-full ' + (orderBtnClass[order.order_status] || 'btn-accent') + '">'
                + orderNextLabel[order.order_status] + '</button></div>';
        }

        var urgentColor = waitMins >= 15 ? 'text-red-600' : (waitMins >= 8 ? 'text-amber-600' : 'text-gray-400');

        html += '<div class="order-card card border-l-4 ' + borderClass + ' ' + urgentClass + ' p-0 overflow-hidden" data-order-id="' + order.id + '">'
            + '<div class="flex items-center justify-between px-4 py-3 border-b border-gray-100">'
            + '<div class="flex items-center gap-2">'
            + '<span class="w-9 h-9 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 font-bold text-sm">' + esc(order.table_number) + '</span>'
            + '<div><p class="font-bold text-sm">Table ' + order.table_number + '</p><p class="text-xs text-gray-400">#' + order.id + ' &bull; ' + order.source + '</p></div>'
            + '</div>'
            + '<div class="text-right"><span class="text-xs font-medium ' + urgentColor + '">' + waitMins + 'm ago</span><p class="text-xs text-gray-400">' + timeStr + '</p></div>'
            + '</div>'
            + '<div class="px-4 py-3 space-y-2">' + itemsHtml + '</div>'
            + footerHtml + '</div>';
    });
    grid.innerHTML = html;
}

// Auto-refresh every 10 seconds
function startAutoRefresh() {
    clearInterval(refreshTimer);
    refreshTimer = setInterval(refreshKitchen, 10000);
}

var soundMuted = false;
function toggleMute() {
    soundMuted = !soundMuted;
    var btn = document.getElementById('muteBtn');
    btn.innerHTML = soundMuted ? '<i class="ri-volume-mute-line text-red-400"></i>' : '<i class="ri-volume-up-line"></i>';
    btn.title = soundMuted ? 'Sound muted (click to unmute)' : 'Sound on (click to mute)';
}
// Wrap playDing to respect mute
var _origPlayDing = playDing;
playDing = function() { if (!soundMuted) _origPlayDing(); };

document.addEventListener('DOMContentLoaded', startAutoRefresh);
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
