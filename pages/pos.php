<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/escpos.php';
requireAuth();
requireRole('admin', 'manager', 'bartender', 'server');

$action = $_POST['action'] ?? '';

// ── AJAX: pending order count (no CSRF needed — read-only GET) ────────────────
if (isset($_GET['ajax']) && $_GET['ajax'] === 'pending_orders') {
    $stmt = db()->prepare("SELECT COUNT(*) FROM bar_orders WHERE status = 'pending' AND source = 'customer'");
    $stmt->execute();
    echo json_encode(['count' => (int)$stmt->fetchColumn()]);
    exit;
}

// ── Background: sync table status — free tables that have no active order ─────
// Runs on every POS load (cheap query, fixes stale "occupied" tables)
try {
    db()->exec("
        UPDATE bar_tables bt
        SET bt.status = 'free'
        WHERE bt.status = 'occupied'
          AND bt.active = 1
          AND NOT EXISTS (
              SELECT 1 FROM bar_orders o
              WHERE o.table_id = bt.id
                AND o.status NOT IN ('closed')
          )
    ");
} catch (Throwable $e) { /* non-fatal */ }

// Verify CSRF token on every state-changing POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

// ── Accept a pending customer order ──────────────────────────────────────────
if ($action === 'accept_order' && !empty($_POST['order_id'])) {
    $id = (int)$_POST['order_id'];
    db()->prepare("UPDATE bar_orders SET status = 'accepted', user_id = ? WHERE id = ?")
        ->execute([$_SESSION['user_id'], $id]);
    auditLog('accept_order', "order #{$id}");
    $_SESSION['active_order_id'] = $id;
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Create new staff order ────────────────────────────────────────────────────
if ($action === 'create_order' && !empty($_POST['table_id'])) {
    $tableId = (int)$_POST['table_id'];
    $stmt = db()->prepare("SELECT id FROM bar_orders WHERE table_id = ? AND status NOT IN ('closed') LIMIT 1");
    $stmt->execute([$tableId]);
    $existing = $stmt->fetch();

    if ($existing) {
        $orderId = $existing['id'];
    } else {
        $stmt = db()->prepare("INSERT INTO bar_orders (table_id, user_id, source, status) VALUES (?, ?, 'staff', 'accepted')");
        $stmt->execute([$tableId, $_SESSION['user_id']]);
        $orderId = db()->lastInsertId();
        db()->prepare("UPDATE `bar_tables` SET status = 'occupied' WHERE id = ?")->execute([$tableId]);
        auditLog('create_order', "order #{$orderId}", "table #{$tableId}");
    }
    $_SESSION['active_order_id'] = $orderId;
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Add item to order ─────────────────────────────────────────────────────────
if ($action === 'add_item' && isset($_POST['order_id'], $_POST['menu_item_id'])) {
    $orderId = (int)$_POST['order_id'];
    $itemId  = (int)$_POST['menu_item_id'];

    $stmt = db()->prepare("SELECT id, price FROM bar_menu_items WHERE id = ? AND active = 1");
    $stmt->execute([$itemId]);
    $item = $stmt->fetch();
    if (!$item) die('Invalid item.');

    if (isMenuItemOutOfStock($itemId)) {
        header('Location: /bar/pages/pos.php?stock_error=1');
        exit;
    }

    $stmt = db()->prepare("SELECT id, quantity FROM bar_order_items WHERE order_id = ? AND menu_item_id = ? AND status = 'ordered'");
    $stmt->execute([$orderId, $itemId]);
    $existing = $stmt->fetch();

    if ($existing) {
        db()->prepare("UPDATE bar_order_items SET quantity = quantity + 1 WHERE id = ?")
            ->execute([$existing['id']]);
    } else {
        db()->prepare("INSERT INTO bar_order_items (order_id, menu_item_id, quantity, unit_price) VALUES (?, ?, 1, ?)")
            ->execute([$orderId, $itemId, $item['price']]);
    }

    recalcOrderTotal($orderId);
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Save item note ────────────────────────────────────────────────────────────
if ($action === 'set_note' && isset($_POST['item_id'])) {
    $id   = (int)$_POST['item_id'];
    $note = trim(mb_substr($_POST['note'] ?? '', 0, 255));
    db()->prepare("UPDATE bar_order_items SET notes = ? WHERE id = ?")->execute([$note ?: null, $id]);
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Update / remove cart item ─────────────────────────────────────────────────
if ($action === 'update_qty' && isset($_POST['item_id'], $_POST['quantity'])) {
    $id  = (int)$_POST['item_id'];
    $qty = max(0, (int)$_POST['quantity']);

    // Fetch order_id BEFORE deleting the row
    $stmt = db()->prepare("SELECT order_id, menu_item_id, quantity FROM bar_order_items WHERE id = ?");
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    $orderId = $row ? (int)$row['order_id'] : null;

    // Only block increases past current stock — decreasing/removing is always allowed
    if ($row && $qty > (int)$row['quantity'] && isMenuItemOutOfStock((int)$row['menu_item_id'])) {
        header('Location: /bar/pages/pos.php?stock_error=1');
        exit;
    }

    if ($qty <= 0) {
        db()->prepare("DELETE FROM bar_order_items WHERE id = ?")->execute([$id]);
    } else {
        db()->prepare("UPDATE bar_order_items SET quantity = ? WHERE id = ?")->execute([$qty, $id]);
    }

    // BUG FIX: always recalc after any quantity change
    if ($orderId) recalcOrderTotal($orderId);

    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Void order (manager/admin only) ──────────────────────────────────────────
if ($action === 'void_order') {
    requireRole('admin', 'manager');
    $orderId = (int)$_POST['order_id'];
    $reason  = trim($_POST['void_reason'] ?? '');
    if (!$reason) die('Void reason is required.');

    db()->beginTransaction();
    try {
        db()->prepare("UPDATE bar_orders SET status = 'closed', voided = 1, void_reason = ?, voided_by = ?, closed_at = NOW() WHERE id = ? AND status != 'closed'")
            ->execute([$reason, $_SESSION['user_id'], $orderId]);

        $stmt = db()->prepare("SELECT table_id FROM bar_orders WHERE id = ?");
        $stmt->execute([$orderId]);
        $ord = $stmt->fetch();
        if ($ord) db()->prepare("UPDATE `bar_tables` SET status = 'free' WHERE id = ?")->execute([$ord['table_id']]);

        db()->commit();
        auditLog('void_order', "order #{$orderId}", "reason: {$reason}");
        unset($_SESSION['active_order_id']);
        header('Location: /bar/pages/pos.php?voided=1');
        exit;
    } catch (Exception $e) {
        db()->rollBack();
        die('Void failed: ' . $e->getMessage());
    }
}

// ── Apply discount ────────────────────────────────────────────────────────────
if ($action === 'apply_discount') {
    $orderId  = (int)$_POST['order_id'];
    $discType = in_array($_POST['discount_type'] ?? '', ['percent','fixed']) ? $_POST['discount_type'] : 'none';
    $discVal  = max(0, (float)str_replace(',', '', $_POST['discount_value'] ?? '0'));
    $stmt = db()->prepare("SELECT total FROM bar_orders WHERE id = ?");
    $stmt->execute([$orderId]);
    $subtotal = (float)$stmt->fetchColumn();
    if ($discType === 'percent') {
        $discVal    = min(100, $discVal);
        $discAmount = round($subtotal * $discVal / 100, 2);
    } elseif ($discType === 'fixed') {
        $discAmount = min($subtotal, $discVal);
    } else {
        $discType = 'none'; $discVal = 0; $discAmount = 0;
    }
    db()->prepare("UPDATE bar_orders SET discount_type=?, discount_value=?, discount_amount=? WHERE id=?")
        ->execute([$discType, $discVal, $discAmount, $orderId]);
    auditLog('apply_discount', "order #{$orderId}", "{$discType} {$discVal} = -{$discAmount}");
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Remove discount ───────────────────────────────────────────────────────────
if ($action === 'remove_discount') {
    $orderId = (int)$_POST['order_id'];
    db()->prepare("UPDATE bar_orders SET discount_type='none', discount_value=0, discount_amount=0 WHERE id=?")
        ->execute([$orderId]);
    header('Location: /bar/pages/pos.php');
    exit;
}

// ── Checkout (supports split payment) ─────────────────────────────────────────
if ($action === 'checkout') {
    $orderId = (int)$_POST['order_id'];
    recalcOrderTotal($orderId);
    $stmt = db()->prepare("SELECT * FROM bar_orders WHERE id = ?");
    $stmt->execute([$orderId]);
    $order = $stmt->fetch();
    if (!$order) die('Order not found.');

    $subtotal      = (float)$order['total'];
    $discAmount    = (float)($order['discount_amount'] ?? 0);
    $afterDiscount = $subtotal - $discAmount;
    $taxAmount     = calcTax($afterDiscount);
    $grandTotal    = round($afterDiscount + $taxAmount, 2);

    // Parse split payment arrays
    $methods = $_POST['methods'] ?? [$_POST['method'] ?? 'cash'];
    $amounts = $_POST['amounts'] ?? [$grandTotal];
    if (!is_array($methods)) $methods = [$methods];
    if (!is_array($amounts)) $amounts = [$amounts];
    $allowed = ['cash','card','transfer','online'];
    $payments = [];
    foreach ($methods as $i => $m) {
        $amt = round((float)str_replace(',', '', $amounts[$i] ?? '0'), 2);
        if ($amt <= 0) continue;
        $payments[] = ['method' => in_array($m, $allowed) ? $m : 'cash', 'amount' => $amt];
    }
    if (empty($payments)) die('No payment entered.');

    db()->beginTransaction();
    try {
        // Lock and re-check availability inside the transaction — closes the race where two
        // staff sell the last unit of something to different tables at the same time.
        $insufficient = checkStockAvailability($orderId);
        if (!empty($insufficient)) {
            db()->rollBack();
            header('Location: /bar/pages/pos.php?stock_error=' . urlencode(implode(', ', $insufficient)));
            exit;
        }

        foreach ($payments as $p) {
            db()->prepare("INSERT INTO bar_payments (order_id, amount, method) VALUES (?, ?, ?)")
                ->execute([$orderId, $p['amount'], $p['method']]);
        }
        db()->prepare("UPDATE bar_orders SET status='closed', paid=1, closed_at=NOW(), subtotal=?, tax_amount=?, total=? WHERE id=?")
            ->execute([$afterDiscount, $taxAmount, $grandTotal, $orderId]);
        db()->prepare("UPDATE `bar_tables` SET status='free' WHERE id=?")->execute([$order['table_id']]);
        depleteInventory($orderId);
        db()->commit();
        $ms = implode('+', array_column($payments, 'method'));
        auditLog('checkout', "order #{$orderId}", "methods:{$ms} total:{$grandTotal}");
        unset($_SESSION['active_order_id']);
        header('Location: /bar/pages/pos.php?receipt=' . $orderId);
        exit;
    } catch (Exception $e) {
        db()->rollBack();
        die('Checkout failed: ' . $e->getMessage());
    }
}

// Note: refunds are issued from the Orders page (pages/orders.php), which has
// the order-detail UI to look up what's still refundable. There is no refund
// entry point on this page.

// ── Helpers ───────────────────────────────────────────────────────────────────
function recalcOrderTotal(int $orderId): void {
    $stmt = db()->prepare("SELECT COALESCE(SUM(quantity * unit_price), 0) FROM bar_order_items WHERE order_id = ?");
    $stmt->execute([$orderId]);
    $subtotal = (float)$stmt->fetchColumn();
    // Store subtotal only; grand total (with tax) is written at checkout
    db()->prepare("UPDATE bar_orders SET total = ? WHERE id = ?")->execute([$subtotal, $orderId]);
}

/**
 * Check every order item has enough linked inventory to fulfil the sale.
 * Locks the relevant inventory rows (FOR UPDATE) so concurrent checkouts on the
 * same stock serialize correctly instead of both succeeding past zero.
 * Returns the names of items that can't be fulfilled (empty = all good).
 */
function checkStockAvailability(int $orderId): array {
    $stmt = db()->prepare("
        SELECT oi.menu_item_id, oi.quantity, mi.name
        FROM bar_order_items oi
        JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
        WHERE oi.order_id = ? AND oi.status != 'cancelled'
    ");
    $stmt->execute([$orderId]);
    $orderItems = $stmt->fetchAll();

    $insufficient = [];
    foreach ($orderItems as $oi) {
        $mapStmt = db()->prepare("
            SELECT inv.quantity, bmi.qty_per_sale
            FROM bar_menu_inventory bmi
            JOIN bar_inventory inv ON inv.id = bmi.inventory_id
            WHERE bmi.menu_item_id = ?
            FOR UPDATE
        ");
        $mapStmt->execute([$oi['menu_item_id']]);
        foreach ($mapStmt->fetchAll() as $map) {
            $needed = $oi['quantity'] * $map['qty_per_sale'];
            if ($needed > (float)$map['quantity']) {
                $insufficient[$oi['name']] = true;
            }
        }
    }
    return array_keys($insufficient);
}

function depleteInventory(int $orderId): void {
    $stmt = db()->prepare("SELECT menu_item_id, quantity FROM bar_order_items WHERE order_id = ?");
    $stmt->execute([$orderId]);
    $orderItems = $stmt->fetchAll();

    $affectedInventoryIds = [];

    foreach ($orderItems as $oi) {
        $mapStmt = db()->prepare("SELECT inventory_id, qty_per_sale FROM bar_menu_inventory WHERE menu_item_id = ?");
        $mapStmt->execute([$oi['menu_item_id']]);
        $mappings = $mapStmt->fetchAll();

        foreach ($mappings as $map) {
            $deduct = $oi['quantity'] * $map['qty_per_sale'];
            db()->prepare("UPDATE bar_inventory SET quantity = GREATEST(0, quantity - ?) WHERE id = ?")
                ->execute([$deduct, $map['inventory_id']]);
            db()->prepare("INSERT INTO bar_inventory_transactions (inventory_id, type, quantity, note) VALUES (?, 'out', ?, ?)")
                ->execute([$map['inventory_id'], $deduct, "Auto: order #{$orderId}"]);
            $affectedInventoryIds[] = (int)$map['inventory_id'];
        }
    }

    // Auto-deactivate/reactivate menu items based on updated stock
    foreach (array_unique($affectedInventoryIds) as $invId) {
        syncMenuItemAvailability($invId);
    }
}

$activeOrderId = $_SESSION['active_order_id'] ?? null;
$receiptId = $_GET['receipt'] ?? null;

// ── Load page data (header must come before any HTML output) ─────────────────
if (!defined('BAR_HEADER_LOADED')) {
    $_standalone = true;
    require __DIR__ . '/../includes/header.php';
} else {
    $_standalone = false;
}

// Fetch free tables
$tables = db()->query("SELECT id, number, capacity, status FROM `bar_tables` WHERE active = 1 ORDER BY number")->fetchAll();

// Fetch categories with items + low-stock state from inventory mappings
$categories = db()->query("SELECT * FROM bar_categories ORDER BY sort_order")->fetchAll();
$menuItems  = db()->query("
    SELECT mi.*, c.name AS category_name,
           -- minimum stock ratio across all linked inventory items (NULL = no mapping)
           MIN(CASE
               WHEN inv.quantity IS NULL THEN NULL
               WHEN inv.quantity <= 0    THEN 0
               WHEN inv.quantity <= inv.low_stock_threshold THEN 1
               ELSE 2
           END) AS stock_state
    FROM bar_menu_items mi
    JOIN bar_categories c ON c.id = mi.category_id
    LEFT JOIN bar_menu_inventory bmi ON bmi.menu_item_id = mi.id
    LEFT JOIN bar_inventory inv ON inv.id = bmi.inventory_id
    WHERE mi.active = 1
    GROUP BY mi.id
    ORDER BY c.sort_order, mi.name
")->fetchAll();

$menuByCategory = [];
foreach ($menuItems as $item) {
    $menuByCategory[$item['category_name']][] = $item;
}

// Active order details
$orderDetails = null;
$orderItems   = [];
if ($activeOrderId) {
    $stmt = db()->prepare("SELECT o.*, t.number AS table_number FROM bar_orders o JOIN `bar_tables` t ON t.id = o.table_id WHERE o.id = ?");
    $stmt->execute([$activeOrderId]);
    $orderDetails = $stmt->fetch();

    if ($orderDetails) {
        $stmt = db()->prepare("SELECT oi.*, mi.name AS item_name FROM bar_order_items oi JOIN bar_menu_items mi ON mi.id = oi.menu_item_id WHERE oi.order_id = ? ORDER BY oi.id");
        $stmt->execute([$activeOrderId]);
        $orderItems = $stmt->fetchAll();
    }}

// Pending customer orders
$pendingOrders = db()->prepare("
    SELECT o.*, t.number AS table_number
    FROM bar_orders o
    JOIN `bar_tables` t ON t.id = o.table_id
    WHERE o.status = 'pending' AND o.source = 'customer'
    ORDER BY o.created_at ASC
");
$pendingOrders->execute();
$pendingOrders = $pendingOrders->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-shopping-cart-2-line text-amber-500 mr-1"></i> Point of Sale</h2>
        <?php if (!$activeOrderId && !$receiptId): ?>
        <span class="text-xs text-gray-400 hidden md:inline"><?= count($tables) ?> tables</span>
        <?php endif; ?>
    </div>

    <!-- Voided notice -->
    <?php if (isset($_GET['voided'])): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-forbid-line text-red-500"></i> Order voided successfully.
    </div>
    <?php endif; ?>

    <!-- Out-of-stock notice -->
    <?php if (isset($_GET['stock_error'])): ?>
    <?php $stockErrorItems = is_string($_GET['stock_error']) ? trim($_GET['stock_error']) : ''; ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-alert-line text-red-500"></i>
        <?= $stockErrorItems && $stockErrorItems !== '1' ? 'Out of stock: ' . e($stockErrorItems) : 'That item is out of stock.' ?>
    </div>
    <?php endif; ?>

    <!-- Receipt display -->
    <?php if ($receiptId): ?>
    <?php
    $rStmt = db()->prepare("SELECT oi.*, mi.name FROM bar_order_items oi JOIN bar_menu_items mi ON mi.id = oi.menu_item_id WHERE oi.order_id = ?");
    $rStmt->execute([$receiptId]);
    $rItems = $rStmt->fetchAll();
    $rStmt2 = db()->prepare("SELECT * FROM bar_orders WHERE id = ?");
    $rStmt2->execute([$receiptId]);
    $rOrder = $rStmt2->fetch();
    $rTax = (float)($rOrder['tax_amount'] ?? 0);
    $rSubtotal = (float)($rOrder['subtotal'] ?? $rOrder['total']);
    $rEscPosPayload = base64_encode(buildReceiptEscPos(
        $rOrder, $rItems,
        getSetting('bar_name', 'The Bar'),
        getSetting('bar_address', ''),
        getSetting('receipt_footer', 'Thank you!')
    ));
    ?>
    <div class="card mb-6">
        <div id="receipt">
            <div class="text-center">
                <h2 class="text-lg font-bold"><?= e(getSetting('bar_name', 'The Bar')) ?></h2>
                <p class="text-[10px] text-gray-500"><?= e(getSetting('bar_address', '')) ?></p>
                <p class="text-[10px] text-gray-500"><?= date('Y-m-d H:i:s') ?></p>
                <hr class="my-2 border-t border-dashed border-gray-400">
            </div>
            <table class="receipt-table">
                <?php foreach ($rItems as $ri): ?>
                <tr>
                    <td><?= e($ri['name']) ?> ×<?= $ri['quantity'] ?></td>
                    <td class="text-right"><?= money($ri['quantity'] * $ri['unit_price']) ?></td>
                </tr>
                <?php endforeach; ?>
            </table>
            <hr class="my-2 border-t border-dashed border-gray-400">
            <div class="text-sm space-y-0.5">
                <div class="flex justify-between"><span>Subtotal</span><span><?= money($rSubtotal) ?></span></div>
                <?php if ($rTax > 0): ?>
                <div class="flex justify-between text-gray-500"><span>Tax (<?= getTaxRate() ?>%)</span><span><?= money($rTax) ?></span></div>
                <?php endif; ?>
                <div class="flex justify-between font-bold text-base pt-1 border-t border-dashed border-gray-300 mt-1">
                    <span>Total</span><span><?= money($rOrder['total']) ?></span>
                </div>
            </div>
            <p class="text-center text-[10px] mt-3 text-gray-500"><?= e(getSetting('receipt_footer', 'Thank you!')) ?></p>
        </div>
        <div class="flex gap-2 mt-4 flex-wrap">
            <button onclick="window.print()" class="btn btn-primary"><i class="ri-printer-line"></i> Print Receipt</button>
            <button onclick="printThermal(this)" data-payload="<?= e($rEscPosPayload) ?>" class="btn btn-outline">
                <i class="ri-printer-cloud-line"></i> Print via Thermal Printer
            </button>
            <a href="/bar/pages/pos.php" class="btn btn-outline">New Order</a>
        </div>
        <p id="thermalPrintStatus" class="text-xs mt-2"></p>
    </div>
    <?php unset($_SESSION['active_order_id']); ?>
    <?php endif; ?>

    <?php if ($pendingOrders && !$activeOrderId): ?>
    <div class="card mb-4 border-l-4 border-amber-400 bg-amber-50/30">
        <div class="flex items-center justify-between mb-3">
            <h3 class="font-semibold text-amber-800"><i class="ri-alarm-warning-line mr-1"></i> Pending Customer Orders</h3>
            <span class="text-xs text-amber-600 font-medium"><?= count($pendingOrders) ?> waiting</span>
        </div>
        <div class="space-y-2">
            <?php foreach ($pendingOrders as $po): ?>
            <div class="flex items-center justify-between p-3 rounded-lg bg-white border border-amber-200 shadow-sm">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 font-bold text-sm">
                        <?= $po['table_number'] ?>
                    </div>
                    <div>
                        <p class="font-semibold text-sm">Table <?= $po['table_number'] ?></p>
                        <p class="text-xs text-gray-500"><?= money($po['total']) ?> • <?= date('H:i', strtotime($po['created_at'])) ?></p>
                    </div>
                </div>
                <form method="POST" class="inline">
                    <input type="hidden" name="action" value="accept_order">
                    <?= csrfField() ?>
                    <input type="hidden" name="order_id" value="<?= $po['id'] ?>">
                    <button type="submit" class="btn btn-accent btn-sm"><i class="ri-check-line"></i> Accept</button>
                </form>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

    <?php if (!$activeOrderId && !$receiptId): ?>
    <!-- Table selection -->
    <div class="card mb-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="font-semibold"><i class="ri-table-line text-amber-500 mr-1"></i> Select Table</h3>
            <span class="text-xs text-gray-400"><?= count($tables) ?> tables</span>
        </div>
        <div class="grid grid-cols-5 md:grid-cols-10 gap-2">
            <?php foreach ($tables as $t): ?>
            <form method="POST">
                <input type="hidden" name="action" value="create_order">
                <input type="hidden" name="csrf" value="">
                <?= csrfField() ?>
                <input type="hidden" name="table_id" value="<?= $t['id'] ?>">
                <button type="submit" class="table-btn <?= $t['status'] ?>"
                    <?= $t['status'] !== 'free' ? 'disabled' : '' ?>>
                    <?= $t['number'] ?>
                </button>
            </form>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

    <?php if ($activeOrderId && $orderDetails): ?>
    <!-- Active order POS -->
    <div class="pos-grid">
        <!-- Menu grid -->
        <div class="overflow-y-auto">
            <div class="flex gap-2 mb-3">
                <div class="relative flex-1">
                    <i class="ri-search-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i>
                    <input type="text" id="menuSearch" placeholder="Search items..." class="form-input pl-9 text-sm" oninput="filterMenu()">
                </div>
            </div>
            <div class="flex gap-2 mb-4 flex-wrap overflow-x-auto pb-1">
                <button class="category-filter-btn active" data-cat="all" onclick="filterCategory('all', this)">All</button>
                <?php foreach ($categories as $cat): ?>
                <button class="category-filter-btn" data-cat="<?= e($cat['name']) ?>" onclick="filterCategory('<?= e($cat['name']) ?>', this)"><?= e($cat['name']) ?></button>
                <?php endforeach; ?>
            </div>

            <?php foreach ($menuByCategory as $catName => $items): ?>
            <div class="category-group mb-4" data-category="<?= e($catName) ?>">
                <h4 class="font-semibold text-gray-500 text-xs uppercase tracking-wider mb-2"><?= e($catName) ?></h4>
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                    <?php foreach ($items as $item):
                        $stockState = $item['stock_state']; // 0=out, 1=low, 2=ok, null=no mapping
                        $stockClass = match(true) {
                            $stockState === '0' || $stockState === 0 => 'out-of-stock',
                            $stockState === '1' || $stockState === 1 => 'low-stock',
                            default => '',
                        };
                    ?>
                    <form method="POST">
                        <input type="hidden" name="action" value="add_item">
                        <?= csrfField() ?>
                        <input type="hidden" name="order_id" value="<?= $activeOrderId ?>">
                        <input type="hidden" name="menu_item_id" value="<?= $item['id'] ?>">
                        <button type="submit" class="pos-menu-item w-full text-left <?= $stockClass ?>" data-name="<?= e(strtolower($item['name'])) ?>"
                            <?= $stockClass === 'out-of-stock' ? 'disabled title="Out of stock"' : '' ?>>
                            <p class="font-medium text-sm"><?= e($item['name']) ?></p>
                            <p class="item-price text-sm mt-1"><?= money($item['price']) ?></p>
                            <?php if ($stockClass === 'low-stock'): ?>
                            <p class="text-[10px] text-amber-600 font-semibold mt-0.5">⚠ Low stock</p>
                            <?php endif; ?>
                        </button>
                    </form>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>

        <!-- Cart -->
        <div class="pos-cart">
            <div class="pos-cart-header">
                <div>
                    <h3 class="font-bold flex items-center gap-2">
                        <span class="w-7 h-7 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 text-xs font-bold"><?= $orderDetails['table_number'] ?></span>
                        Table <?= $orderDetails['table_number'] ?>
                    </h3>
                    <p class="text-xs text-gray-500 mt-0.5">
                        <?= count($orderItems) ?> item<?= count($orderItems) !== 1 ? 's' : '' ?>
                        <span class="mx-1">•</span> Order #<?= $activeOrderId ?>
                    </p>
                </div>
                <span class="text-xl font-bold text-amber-600"><?= money($orderDetails['total']) ?></span>
            </div>

            <div class="flex-1 overflow-y-auto space-y-1">
                <?php foreach ($orderItems as $oi): ?>
                <div class="flex flex-col px-2 py-2 rounded-lg hover:bg-gray-50 transition">
                    <div class="flex items-center justify-between">
                        <div class="min-w-0 flex-1">
                            <p class="font-medium text-sm truncate"><?= e($oi['item_name']) ?></p>
                            <p class="text-xs text-gray-500"><?= money($oi['unit_price']) ?> each</p>
                        </div>
                        <div class="flex items-center gap-2 flex-shrink-0">
                            <form method="POST" class="inline">
                                <input type="hidden" name="action" value="update_qty">
                                <?= csrfField() ?>
                                <input type="hidden" name="item_id" value="<?= $oi['id'] ?>">
                                <input type="hidden" name="quantity" value="<?= $oi['quantity'] - 1 ?>">
                                <button type="submit" class="w-7 h-7 rounded-full border border-gray-200 flex items-center justify-center text-gray-500 hover:text-red-500 hover:border-red-300 transition text-sm">−</button>
                            </form>
                            <span class="text-sm font-medium w-5 text-center"><?= $oi['quantity'] ?></span>
                            <form method="POST" class="inline">
                                <input type="hidden" name="action" value="update_qty">
                                <?= csrfField() ?>
                                <input type="hidden" name="item_id" value="<?= $oi['id'] ?>">
                                <input type="hidden" name="quantity" value="<?= $oi['quantity'] + 1 ?>">
                                <button type="submit" class="w-7 h-7 rounded-full border border-gray-200 flex items-center justify-center text-gray-500 hover:text-green-500 hover:border-green-300 transition text-sm">+</button>
                            </form>
                            <span class="text-sm font-bold w-16 text-right text-gray-700"><?= money($oi['quantity'] * $oi['unit_price']) ?></span>
                        </div>
                    </div>
                    <!-- Item note / special request -->
                    <?php if (!empty($oi['notes'])): ?>
                    <p class="text-xs text-amber-600 italic mt-0.5 pl-0.5">📝 <?= e($oi['notes']) ?></p>
                    <?php endif; ?>
                    <form method="POST" class="flex gap-1 mt-1" id="noteForm<?= $oi['id'] ?>" style="display:<?= empty($oi['notes']) ? 'none' : 'flex' ?> !important">
                        <input type="hidden" name="action" value="set_note">
                        <?= csrfField() ?>
                        <input type="hidden" name="item_id" value="<?= $oi['id'] ?>">
                        <input type="text" name="note" value="<?= e($oi['notes'] ?? '') ?>" placeholder="e.g. no ice, double shot…"
                               class="form-input text-xs py-1 flex-1" maxlength="255">
                        <button type="submit" class="btn btn-ghost btn-sm text-green-600 py-1 px-2">✓</button>
                        <button type="button" onclick="toggleNoteForm(<?= $oi['id'] ?>)" class="btn btn-ghost btn-sm text-gray-400 py-1 px-2">✕</button>
                    </form>
                    <?php if (empty($oi['notes'])): ?>
                    <button type="button" onclick="toggleNoteForm(<?= $oi['id'] ?>)"
                        class="text-xs text-gray-400 hover:text-amber-600 text-left mt-0.5 pl-0.5">
                        + add note
                    </button>
                    <?php endif; ?>
                </div>
                <?php endforeach; ?>
                <?php if (empty($orderItems)): ?>
                <div class="empty-state">
                    <i class="ri-shopping-bag-line"></i>
                    <p>Cart is empty</p>
                    <p class="text-xs text-gray-400 mt-1">Tap items from the menu to add them</p>
                </div>
                <?php endif; ?>
            </div>

            <?php if (!empty($orderItems)): ?>
            <div class="border-t pt-3 mt-3 space-y-2">
                <?php
                $subtotal     = (float)$orderDetails['total'];
                $discAmount   = (float)($orderDetails['discount_amount'] ?? 0);
                $discType     = $orderDetails['discount_type'] ?? 'none';
                $discValue    = (float)($orderDetails['discount_value'] ?? 0);
                $afterDiscount = $subtotal - $discAmount;
                $taxAmt       = calcTax($afterDiscount);
                $grandTotal   = round($afterDiscount + $taxAmt, 2);
                $taxRate      = getTaxRate();
                ?>
                <div class="text-xs text-gray-500 space-y-0.5 pb-2 border-b">
                    <div class="flex justify-between"><span>Subtotal</span><span><?= money($subtotal) ?></span></div>
                    <?php if ($discAmount > 0): ?>
                    <div class="flex justify-between text-green-600">
                        <span>Discount <?= $discType === 'percent' ? "({$discValue}%)" : "(fixed)" ?></span>
                        <span>−<?= money($discAmount) ?></span>
                    </div>
                    <?php endif; ?>
                    <?php if ($taxRate > 0): ?>
                    <div class="flex justify-between"><span>Tax (<?= $taxRate ?>%)</span><span><?= money($taxAmt) ?></span></div>
                    <?php endif; ?>
                    <div class="flex justify-between font-bold text-gray-700 text-sm pt-1 border-t border-gray-100">
                        <span>Total</span><span><?= money($grandTotal) ?></span>
                    </div>
                </div>

                <!-- Discount row -->
                <?php if ($discAmount > 0): ?>
                <div class="flex items-center justify-between bg-green-50 rounded-lg px-3 py-1.5 text-xs text-green-700">
                    <span>✓ Discount applied</span>
                    <form method="POST" class="inline">
                        <?= csrfField() ?>
                        <input type="hidden" name="action" value="remove_discount">
                        <input type="hidden" name="order_id" value="<?= $activeOrderId ?>">
                        <button type="submit" class="text-red-400 hover:text-red-600 ml-2">✕ Remove</button>
                    </form>
                </div>
                <?php else: ?>
                <button onclick="document.getElementById('discountModal').classList.remove('hidden')"
                    class="btn btn-ghost btn-sm w-full text-green-600 hover:bg-green-50">
                    <i class="ri-percent-line"></i> Add Discount
                </button>
                <?php endif; ?>

                <!-- Split payment / checkout form -->
                <form method="POST" id="checkoutForm">
                    <?= csrfField() ?>
                    <input type="hidden" name="action" value="checkout">
                    <input type="hidden" name="order_id" value="<?= $activeOrderId ?>">

                    <div id="paymentSplits" class="space-y-2">
                        <div class="flex gap-2 payment-split-row">
                            <select name="methods[]" class="form-select flex-1 text-sm">
                                <option value="cash">Cash</option>
                                <option value="card">Card</option>
                                <option value="transfer">Transfer</option>
                            </select>
                            <input type="number" step="0.01" min="0" name="amounts[]"
                                   value="<?= $grandTotal ?>" class="form-input w-28 text-sm split-amount">
                            <button type="button" onclick="removePaymentRow(this)" class="text-red-400 hover:text-red-600 px-1 hidden remove-split-btn">✕</button>
                        </div>
                    </div>

                    <div class="flex items-center justify-between text-xs text-gray-400 mt-1 mb-2">
                        <button type="button" onclick="addPaymentSplit()" class="text-blue-500 hover:underline">
                            + Split payment
                        </button>
                        <span>Remaining: <strong id="splitRemaining"><?= money($grandTotal) ?></strong></span>
                    </div>

                    <button type="submit" class="btn btn-accent w-full">
                        <i class="ri-bill-line"></i> Checkout <?= money($grandTotal) ?>
                    </button>
                </form>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <button onclick="document.getElementById('voidModal').classList.remove('hidden')"
                    class="btn btn-ghost btn-sm w-full text-red-500 hover:bg-red-50">
                    <i class="ri-forbid-line"></i> Void Order
                </button>
                <?php endif; ?>
            </div>
            <?php endif; ?>
        </div>
    </div>
    <?php endif; ?>
</div>

<?php if ($activeOrderId && in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
<!-- Void Order Modal -->
<div id="voidModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title text-red-600"><i class="ri-forbid-line mr-1"></i> Void Order #<?= $activeOrderId ?></h3>
            <button type="button" onclick="document.getElementById('voidModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <p class="text-sm text-gray-600 mb-4">This will cancel the order and free the table. Action is logged and cannot be undone.</p>
        <form method="POST">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="void_order">
            <input type="hidden" name="order_id" value="<?= $activeOrderId ?>">
            <div class="form-group">
                <label class="form-label">Reason for void <span class="text-red-500">*</span></label>
                <textarea name="void_reason" class="form-textarea" rows="2" placeholder="e.g. Customer left, wrong order, duplicate..." required></textarea>
            </div>
            <div class="flex gap-2 mt-2">
                <button type="submit" class="btn btn-danger flex-1"><i class="ri-forbid-line"></i> Confirm Void</button>
                <button type="button" onclick="document.getElementById('voidModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Discount Modal -->
<div id="discountModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title text-green-700"><i class="ri-percent-line mr-1"></i> Apply Discount</h3>
            <button type="button" onclick="document.getElementById('discountModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="apply_discount">
            <input type="hidden" name="order_id" value="<?= $activeOrderId ?>">
            <div class="space-y-3">
                <div>
                    <label class="form-label">Discount Type</label>
                    <select name="discount_type" id="discountType" class="form-select" onchange="updateDiscountLabel()">
                        <option value="percent">Percentage (%)</option>
                        <option value="fixed">Fixed Amount (₦)</option>
                    </select>
                </div>
                <div>
                    <label class="form-label" id="discountValueLabel">Discount (%)</label>
                    <input type="number" name="discount_value" step="0.01" min="0" class="form-input" placeholder="e.g. 10" required>
                </div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Apply</button>
                <button type="button" onclick="document.getElementById('discountModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>
<?php endif; ?>

<script>
function toggleNoteForm(itemId) {
    var form = document.getElementById('noteForm' + itemId);
    if (!form) return;
    var isHidden = form.style.display === 'none' || form.style.display === '';
    form.style.setProperty('display', isHidden ? 'flex' : 'none', 'important');
    if (isHidden) form.querySelector('input[name="note"]').focus();
}

function filterCategory(cat, btn) {
    document.querySelectorAll('.category-filter-btn').forEach(function(b) {
        b.classList.remove('active');
    });
    btn.classList.add('active');
    document.querySelectorAll('.category-group').forEach(function(g) {
        var match = cat === 'all' || g.dataset.category === cat;
        g.style.display = match ? '' : 'none';
    });
    filterMenu();
}

function filterMenu() {
    var query = (document.getElementById('menuSearch').value || '').toLowerCase();
    var activeCat = document.querySelector('.category-filter-btn.active');
    var cat = activeCat ? activeCat.dataset.cat : 'all';

    document.querySelectorAll('.category-group').forEach(function(g) {
        var catMatch = cat === 'all' || g.dataset.category === cat;
        g.style.display = catMatch ? '' : 'none';
    });

    document.querySelectorAll('.pos-menu-item').forEach(function(btn) {
        var name = (btn.dataset.name || '').toLowerCase();
        var match = !query || name.indexOf(query) !== -1;
        btn.closest('form').style.display = match ? '' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', function() {
    // .category-filter-btn only exists on the active-order view (menu + cart) —
    // this script tag is also present on the table-select and receipt views,
    // where there's nothing to filter.
    var firstCategoryBtn = document.querySelector('.category-filter-btn');
    if (firstCategoryBtn) filterCategory('all', firstCategoryBtn);
    updateSplitRemaining();
});

// ── Split payment ─────────────────────────────────────────────────────────────
var GRAND_TOTAL = <?= isset($grandTotal) ? (float)$grandTotal : 0 ?>;

function addPaymentSplit() {
    var container = document.getElementById('paymentSplits');
    if (!container) return;
    var row = document.createElement('div');
    row.className = 'flex gap-2 payment-split-row';
    row.innerHTML = '<select name="methods[]" class="form-select flex-1 text-sm">'
        + '<option value="cash">Cash</option>'
        + '<option value="card">Card</option>'
        + '<option value="transfer">Transfer</option>'
        + '</select>'
        + '<input type="number" step="0.01" min="0" name="amounts[]" value="0"'
        + ' class="form-input w-28 text-sm split-amount" oninput="updateSplitRemaining()">'
        + '<button type="button" onclick="removePaymentRow(this)"'
        + ' class="text-red-400 hover:text-red-600 px-1 remove-split-btn">✕</button>';
    container.appendChild(row);
    document.querySelectorAll('.remove-split-btn').forEach(function(b) {
        b.classList.remove('hidden');
    });
    updateSplitRemaining();
}

function removePaymentRow(btn) {
    btn.closest('.payment-split-row').remove();
    var rows = document.querySelectorAll('.payment-split-row');
    if (rows.length === 1) {
        rows[0].querySelector('.remove-split-btn').classList.add('hidden');
    }
    updateSplitRemaining();
}

function updateSplitRemaining() {
    var total = 0;
    document.querySelectorAll('.split-amount').forEach(function(inp) {
        total += parseFloat(inp.value) || 0;
    });
    var rem = Math.round((GRAND_TOTAL - total) * 100) / 100;
    var el = document.getElementById('splitRemaining');
    if (!el) return;
    if (rem > 0.01) {
        el.textContent = '₦' + rem.toFixed(2) + ' left';
        el.style.color = '#dc2626';
    } else if (rem < -0.01) {
        el.textContent = '₦' + Math.abs(rem).toFixed(2) + ' over';
        el.style.color = '#dc2626';
    } else {
        el.textContent = '✓ Balanced';
        el.style.color = '#059669';
    }
}

document.addEventListener('input', function(e) {
    if (e.target.classList.contains('split-amount')) updateSplitRemaining();
});

// ── Discount modal label ──────────────────────────────────────────────────────
function updateDiscountLabel() {
    var type  = document.getElementById('discountType');
    var label = document.getElementById('discountValueLabel');
    if (type && label) {
        label.textContent = type.value === 'percent' ? 'Discount (%)' : 'Discount Amount (₦)';
    }
}

// ── Thermal receipt printing ─────────────────────────────────────────────────
// Talks to a local print-agent (bin/print-agent.php) that must be running on
// THIS machine, listening on 127.0.0.1:9100 — see PRINTING.md for setup. The
// agent is a separate localhost-only process because a browser can't write to
// a USB device directly.
var PRINT_AGENT_URL = 'http://127.0.0.1:9100/print';

function printThermal(btn) {
    var statusEl = document.getElementById('thermalPrintStatus');
    var payload = btn.dataset.payload;
    btn.disabled = true;
    if (statusEl) { statusEl.textContent = 'Sending to printer…'; statusEl.className = 'text-xs mt-2 text-gray-400'; }

    fetch(PRINT_AGENT_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: payload })
    })
    .then(function(r) { return r.json().then(function(json) { return { ok: r.ok, json: json }; }); })
    .then(function(result) {
        btn.disabled = false;
        if (!statusEl) return;
        if (result.ok && result.json.ok) {
            statusEl.textContent = '✓ Sent to printer.';
            statusEl.className = 'text-xs mt-2 text-green-600';
        } else {
            statusEl.textContent = '✗ ' + (result.json.error || 'Print failed.');
            statusEl.className = 'text-xs mt-2 text-red-600';
        }
    })
    .catch(function() {
        btn.disabled = false;
        if (statusEl) {
            statusEl.textContent = '✗ Could not reach the local print agent — is it running on this machine? See PRINTING.md.';
            statusEl.className = 'text-xs mt-2 text-red-600';
        }
    });
}
</script>
<script src="/bar/public/js/pos.js"></script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>