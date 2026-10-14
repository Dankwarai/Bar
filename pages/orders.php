<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
ensureOrderPaymentMethodColumn();

// ── AJAX: refund from orders page ─────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'refund') {
    verifyCsrf();
    requireRole('admin', 'manager');
    $orderId = (int)$_POST['order_id'];
    $amount  = round((float)str_replace(',', '', $_POST['refund_amount'] ?? '0'), 2);
    $reason  = trim($_POST['refund_reason'] ?? '');
    $method  = in_array($_POST['refund_method'] ?? '', ['cash', 'card', 'transfer', 'online'], true)
        ? $_POST['refund_method'] : 'cash';

    if ($amount <= 0 || !$reason) {
        header('Location: /bar/pages/orders.php?refund_error=invalid');
        exit;
    }

    $maxRefundable = remainingRefundable($orderId);
    if ($amount > $maxRefundable) {
        header('Location: /bar/pages/orders.php?refund_error=exceeds');
        exit;
    }

    try {
        db()->prepare("INSERT INTO bar_refunds (order_id, user_id, amount, method, reason) VALUES (?, ?, ?, ?, ?)")
            ->execute([$orderId, $_SESSION['user_id'], $amount, $method, $reason]);
        auditLog('refund', "order #{$orderId}", "amount:{$amount} method:{$method} reason:{$reason}");
        header('Location: /bar/pages/orders.php?refunded=' . $orderId);
    } catch (Exception $e) {
        header('Location: /bar/pages/orders.php?refund_error=failed');
    }
    exit;
}
if (isset($_GET['ajax']) && $_GET['ajax'] === 'detail' && isset($_GET['id'])) {
    $id = (int)$_GET['id'];
    $oStmt = db()->prepare("
        SELECT o.*, t.number AS table_number, u.name AS staff_name
        FROM bar_orders o
        LEFT JOIN `bar_tables` t ON t.id = o.table_id
        LEFT JOIN bar_users u ON u.id = o.user_id
        WHERE o.id = ?
    ");
    $oStmt->execute([$id]);
    $order = $oStmt->fetch();

    $iStmt = db()->prepare("
        SELECT oi.quantity, oi.unit_price, oi.status, oi.notes,
               mi.name AS item_name
        FROM bar_order_items oi
        JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
        WHERE oi.order_id = ?
        ORDER BY oi.id
    ");
    $iStmt->execute([$id]);
    $items = $iStmt->fetchAll();

    $pStmt = db()->prepare("SELECT method, amount, reference, created_at FROM bar_payments WHERE order_id = ? ORDER BY id");
    $pStmt->execute([$id]);
    $payments = $pStmt->fetchAll();

    $rStmt = db()->prepare("SELECT amount, method, reason, created_at FROM bar_refunds WHERE order_id = ? ORDER BY id");
    $rStmt->execute([$id]);
    $refunds = $rStmt->fetchAll();

    echo json_encode([
        'order' => $order,
        'items' => $items,
        'payments' => $payments,
        'refunds' => $refunds,
        'max_refundable' => remainingRefundable($id),
    ]);
    exit;
}

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$statusFilter = $_GET['status'] ?? '';
$page    = max(1, (int)($_GET['page'] ?? 1));
$perPage = 50;
$offset  = ($page - 1) * $perPage;

// ── Single JOIN query — no N+1 ─────────────────────────────────────────────
$countSql = "SELECT COUNT(DISTINCT o.id) FROM bar_orders o";
$sql = "
    SELECT o.id, o.status, o.source, o.payment_method, o.paid, o.created_at,
           o.total, o.subtotal, o.tax_amount, o.voided,
           t.number AS table_number,
           u.name   AS staff_name,
           COUNT(oi.id) AS item_count
    FROM bar_orders o
    LEFT JOIN `bar_tables` t  ON t.id  = o.table_id
    LEFT JOIN bar_users    u  ON u.id  = o.user_id
    LEFT JOIN bar_order_items oi ON oi.order_id = o.id
";
$params = [];
if ($statusFilter) {
    $sql      .= " WHERE o.status = ?";
    $countSql .= " WHERE o.status = ?";
    $params[]  = $statusFilter;
}
$sql .= " GROUP BY o.id ORDER BY o.created_at DESC LIMIT {$perPage} OFFSET {$offset}";

$countStmt = db()->prepare($countSql);
$countStmt->execute($params);
$total      = (int)$countStmt->fetchColumn();
$totalPages = max(1, ceil($total / $perPage));

$stmt = db()->prepare($sql);
$stmt->execute($params);
$orders = $stmt->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-file-list-3-line text-amber-500 mr-1"></i> Orders</h2>
        <div class="flex gap-2 flex-wrap">
            <a href="/bar/pages/orders.php"               class="btn btn-sm <?= !$statusFilter ? 'btn-primary' : 'btn-outline' ?>">All</a>
            <a href="/bar/pages/orders.php?status=pending"  class="btn btn-sm <?= $statusFilter === 'pending'  ? 'btn-primary' : 'btn-outline' ?>">Pending</a>
            <a href="/bar/pages/orders.php?status=accepted" class="btn btn-sm <?= $statusFilter === 'accepted' ? 'btn-primary' : 'btn-outline' ?>">Accepted</a>
            <a href="/bar/pages/orders.php?status=closed"   class="btn btn-sm <?= $statusFilter === 'closed'   ? 'btn-primary' : 'btn-outline' ?>">Closed</a>
        </div>
    </div>

    <?php if (isset($_GET['refunded'])): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-refund-line text-green-500"></i> Refund recorded successfully.
    </div>
    <?php elseif (($_GET['refund_error'] ?? '') === 'exceeds'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> Refund amount exceeds what's still refundable on that order.
    </div>
    <?php elseif (($_GET['refund_error'] ?? '') === 'invalid'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> Refund amount and reason are both required.
    </div>
    <?php elseif (($_GET['refund_error'] ?? '') === 'failed'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> Refund failed. Please try again.
    </div>
    <?php endif; ?>

    <div class="card p-0">
        <div class="p-4">
        <?php if (empty($orders)): ?>
        <div class="empty-state"><i class="ri-file-list-3-line"></i><p>No orders found.</p></div>
        <?php else: ?>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>#</th><th>Table</th><th>Staff</th><th>Items</th><th>Total</th><th>Status</th><th>Source</th><th>Payment</th><th>Paid</th><th>Time</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($orders as $o): ?>
                    <tr class="cursor-pointer hover:bg-amber-50 transition" onclick="showOrderDetail(<?= $o['id'] ?>)" title="Click for details">
                        <td class="font-mono">
                            #<?= $o['id'] ?>
                            <?php if ($o['voided']): ?>
                            <span class="badge bg-red-100 text-red-600 border border-red-200 text-[10px] ml-1">voided</span>
                            <?php endif; ?>
                        </td>
                        <td><?= $o['table_number'] ?></td>
                        <td><?= e($o['staff_name'] ?? '—') ?></td>
                        <td><?= (int)$o['item_count'] ?></td>
                        <td class="font-bold"><?= money($o['total']) ?></td>
                        <td><span class="badge badge-<?= e($o['status']) ?>"><?= e($o['status']) ?></span></td>
                        <td><?= e($o['source']) ?></td>
                        <td><?= e(paymentMethodLabel($o['payment_method'] ?? 'cash')) ?></td>
                        <td><?= $o['paid'] ? '<span class="text-green-600 font-medium">Yes</span>' : '<span class="text-red-500">No</span>' ?></td>
                        <td class="text-sm text-gray-500"><?= date('H:i', strtotime($o['created_at'])) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <?php if ($totalPages > 1): ?>
        <div class="flex items-center justify-between pt-4 mt-2 border-t text-sm">
            <span class="text-gray-500">
                Page <?= $page ?> of <?= $totalPages ?>
                &nbsp;·&nbsp; <?= number_format($total) ?> orders
            </span>
            <div class="flex gap-1">
                <?php if ($page > 1): ?>
                <a href="?page=<?= $page-1 ?>&status=<?= e($statusFilter) ?>" class="btn btn-outline btn-sm">← Prev</a>
                <?php endif; ?>
                <?php if ($page < $totalPages): ?>
                <a href="?page=<?= $page+1 ?>&status=<?= e($statusFilter) ?>" class="btn btn-outline btn-sm">Next →</a>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>
        <?php endif; ?>
        </div>
    </div>
</div>

<!-- Order Detail Modal -->
<div id="orderDetailModal" class="modal-overlay hidden">
    <div class="modal-content max-w-lg">
        <div class="modal-header">
            <h3 class="modal-title" id="detailTitle"><i class="ri-file-list-3-line mr-1"></i> Order Detail</h3>
            <button type="button" onclick="document.getElementById('orderDetailModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <div id="detailBody" class="space-y-4">
            <div class="text-center py-6 text-gray-400"><i class="ri-loader-4-line text-2xl animate-spin"></i></div>
        </div>
    </div>
</div>

<script>
function showOrderDetail(orderId) {
    var modal = document.getElementById('orderDetailModal');
    var body  = document.getElementById('detailBody');
    var title = document.getElementById('detailTitle');
    title.innerHTML = '<i class="ri-file-list-3-line mr-1"></i> Order #' + orderId;
    body.innerHTML  = '<div class="text-center py-8 text-gray-400"><i class="ri-loader-4-line text-3xl"></i><p class="mt-2 text-sm">Loading…</p></div>';
    modal.classList.remove('hidden');

    fetch('/bar/pages/orders.php?ajax=detail&id=' + orderId)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var o = data.order;
            var items = data.items;
            var payments = data.payments;
            var refunds = data.refunds;
            var maxRefundable = parseFloat(data.max_refundable) || 0;

            var statusBadge = '<span class="badge badge-' + esc(o.status) + '">' + esc(o.status) + '</span>';
            if (o.voided == '1') {
                statusBadge += '<span class="badge bg-red-100 text-red-600 border border-red-200 ml-1">VOIDED</span>';
            }

            var html = '<div class="flex flex-wrap gap-4 text-sm mb-4">';
            html += '<div><span class="text-gray-400">Table</span><br><strong>' + esc(o.table_number) + '</strong></div>';
            html += '<div><span class="text-gray-400">Staff</span><br><strong>' + esc(o.staff_name || '—') + '</strong></div>';
            html += '<div><span class="text-gray-400">Source</span><br><strong>' + esc(o.source) + '</strong></div>';
            html += '<div><span class="text-gray-400">Payment</span><br><strong>' + esc(paymentMethodLabel(o.payment_method)) + '</strong></div>';
            html += '<div><span class="text-gray-400">Status</span><br>' + statusBadge + '</div>';
            html += '<div><span class="text-gray-400">Time</span><br><strong>' + esc(o.created_at) + '</strong></div>';
            html += '</div>';

            // Items
            html += '<table class="w-full text-sm mb-4"><thead><tr class="border-b"><th class="text-left py-1">Item</th><th class="text-center py-1">Qty</th><th class="text-right py-1">Price</th><th class="text-right py-1">Line</th></tr></thead><tbody>';
            items.forEach(function(item) {
                var line = (parseFloat(item.quantity) * parseFloat(item.unit_price)).toFixed(2);
                html += '<tr class="border-b border-gray-50">';
                html += '<td class="py-1">' + esc(item.item_name);
                if (item.notes) html += '<br><span class="text-xs text-gray-400 italic">' + esc(item.notes) + '</span>';
                html += '</td>';
                html += '<td class="text-center py-1">' + esc(item.quantity) + '</td>';
                html += '<td class="text-right py-1">₦' + parseFloat(item.unit_price).toFixed(2) + '</td>';
                html += '<td class="text-right py-1 font-medium">₦' + line + '</td>';
                html += '</tr>';
            });
            html += '</tbody></table>';

            // Totals
            html += '<div class="text-sm space-y-0.5 mb-4">';
            if (o.tax_amount > 0) {
                html += '<div class="flex justify-between text-gray-500"><span>Subtotal</span><span>₦' + parseFloat(o.subtotal || o.total).toFixed(2) + '</span></div>';
                html += '<div class="flex justify-between text-gray-500"><span>Tax</span><span>₦' + parseFloat(o.tax_amount).toFixed(2) + '</span></div>';
            }
            html += '<div class="flex justify-between font-bold text-base border-t pt-1 mt-1"><span>Total</span><span>₦' + parseFloat(o.total).toFixed(2) + '</span></div>';
            html += '</div>';

            // Void reason
            if (o.voided == '1' && o.void_reason) {
                html += '<div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-3 py-2 text-sm mb-4">';
                html += '<strong>Void reason:</strong> ' + esc(o.void_reason) + '</div>';
            }

            // Payments
            if (payments && payments.length) {
                html += '<div class="border-t pt-3"><p class="text-xs font-semibold text-gray-500 uppercase mb-2">Payments</p>';
                payments.forEach(function(p) {
                    html += '<div class="flex justify-between text-sm py-0.5">';
                    html += '<span class="capitalize">' + esc(p.method) + (p.reference ? ' <span class="text-gray-400 text-xs">#' + esc(p.reference) + '</span>' : '') + '</span>';
                    html += '<span class="font-medium">₦' + parseFloat(p.amount).toFixed(2) + '</span>';
                    html += '</div>';
                });
                html += '</div>';
            }

            // Refunds already issued
            if (refunds && refunds.length) {
                html += '<div class="border-t pt-3"><p class="text-xs font-semibold text-gray-500 uppercase mb-2">Refunds</p>';
                refunds.forEach(function(r) {
                    html += '<div class="flex justify-between text-sm py-0.5 text-orange-700">';
                    html += '<span class="capitalize">' + esc(r.method) + ' <span class="text-gray-400 text-xs italic">' + esc(r.reason) + '</span></span>';
                    html += '<span class="font-medium">−₦' + parseFloat(r.amount).toFixed(2) + '</span>';
                    html += '</div>';
                });
                html += '</div>';
            }

            // Refund button (admin/manager only, paid orders with a remaining refundable balance)
            <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
            if (o.paid == '1' && maxRefundable > 0.001) {
                html += '<div class="border-t pt-3 mt-3">'
                    + '<button onclick="showRefundForm(' + o.id + ',' + maxRefundable.toFixed(2) + ')"'
                    + ' class="btn btn-outline btn-sm w-full text-orange-600 border-orange-200 hover:bg-orange-50">'
                    + '<i class="ri-refund-line"></i> Issue Partial Refund</button></div>';
            }
            <?php endif; ?>

            body.innerHTML = html;
        })
        .catch(function() {
            body.innerHTML = '<p class="text-red-500 text-sm">Failed to load order details.</p>';
        });
}

function paymentMethodLabel(method) {
    var labels = { cash: 'Cash', pos: 'POS', card: 'Card', online: 'Online' };
    return labels[method || 'cash'] || 'Cash';
}

function esc(str) {
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(String(str || '')));
    return d.innerHTML;
}

function showRefundForm(orderId, maxRefundable) {
    document.getElementById('refundOrderId').value = orderId;
    document.getElementById('refundMax').textContent = '₦' + maxRefundable.toFixed(2);
    var amountInput = document.getElementById('refundAmountInput');
    amountInput.max = maxRefundable.toFixed(2);
    amountInput.value = '';
    document.getElementById('refundModal').classList.remove('hidden');
}
</script><?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
<!-- Refund Modal -->
<div id="refundModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title text-orange-600"><i class="ri-refund-line mr-1"></i> Issue Partial Refund</h3>
            <button type="button" onclick="document.getElementById('refundModal').classList.add('hidden')" class="modal-close">
                <i class="ri-close-line"></i>
            </button>
        </div>
        <p class="text-sm text-gray-500 mb-4">Max refundable: <strong id="refundMax"></strong></p>
        <form method="POST">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="refund">
            <input type="hidden" name="order_id" id="refundOrderId">
            <div class="space-y-3">
                <div>
                    <label class="form-label">Refund Amount (₦) <span class="text-red-500">*</span></label>
                    <input type="number" name="refund_amount" id="refundAmountInput" step="0.01" min="0.01" class="form-input" required placeholder="0.00">
                </div>
                <div>
                    <label class="form-label">Refund Method <span class="text-red-500">*</span></label>
                    <select name="refund_method" class="form-select" required>
                        <option value="cash">Cash</option>
                        <option value="card">Card</option>
                        <option value="transfer">Transfer</option>
                        <option value="online">Online (Paystack)</option>
                    </select>
                    <p class="text-xs text-gray-400 mt-1">How the money is actually being handed back — affects cash reconciliation.</p>
                </div>
                <div>
                    <label class="form-label">Reason <span class="text-red-500">*</span></label>
                    <input type="text" name="refund_reason" class="form-input" required placeholder="e.g. Wrong item served, customer complaint…">
                </div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-danger flex-1">Confirm Refund</button>
                <button type="button" onclick="document.getElementById('refundModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>
<?php endif; ?>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
