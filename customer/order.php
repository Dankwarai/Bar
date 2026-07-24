<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';

if (session_status() === PHP_SESSION_NONE) session_start();

$action = $_POST['action'] ?? '';

// AJAX order submission
if ($action === 'submit_order') {
    $token = $_POST['token'] ?? '';
    $session = $_POST['session'] ?? '';
    $itemsJson = $_POST['items'] ?? '[]';

    $stmt = db()->prepare("SELECT id FROM `bar_tables` WHERE qr_token = ? AND active = 1");
    $stmt->execute([$token]);
    $table = $stmt->fetch();
    if (!$table) {
        echo json_encode(['success' => false, 'message' => 'Invalid table.']);
        exit;
    }

    $cart = json_decode($itemsJson, true);
    if (!is_array($cart) || empty($cart)) {
        echo json_encode(['success' => false, 'message' => 'Cart is empty.']);
        exit;
    }

    // Merge quantities by menu item id — never trust client-supplied price or name.
    $requestedQty = [];
    foreach ($cart as $entry) {
        $itemId = (int)($entry['id'] ?? 0);
        $qty    = (int)($entry['qty'] ?? 0);
        if ($itemId <= 0 || $qty <= 0) continue;
        $qty = min($qty, 50); // sane per-line cap
        $requestedQty[$itemId] = ($requestedQty[$itemId] ?? 0) + $qty;
    }
    if (empty($requestedQty)) {
        echo json_encode(['success' => false, 'message' => 'Cart is empty.']);
        exit;
    }

    // Look up authoritative prices/availability server-side — the client cart is not trusted.
    $ids = array_keys($requestedQty);
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = db()->prepare("SELECT id, price FROM bar_menu_items WHERE id IN ($placeholders) AND active = 1");
    $stmt->execute($ids);
    $menuPrices = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);

    if (count($menuPrices) !== count($ids)) {
        echo json_encode(['success' => false, 'message' => 'One or more items are no longer available. Please refresh the menu.']);
        exit;
    }

    $total = 0;
    foreach ($requestedQty as $itemId => $qty) {
        $total += $menuPrices[$itemId] * $qty;
    }

    db()->beginTransaction();
    try {
        $stmt = db()->prepare("INSERT INTO bar_orders (table_id, source, customer_session, status, total) VALUES (?, 'customer', ?, 'pending', ?)");
        $stmt->execute([$table['id'], $session, $total]);
        $orderId = db()->lastInsertId();

        $stmt = db()->prepare("INSERT INTO bar_order_items (order_id, menu_item_id, quantity, unit_price) VALUES (?, ?, ?, ?)");
        foreach ($requestedQty as $itemId => $qty) {
            $stmt->execute([$orderId, $itemId, $qty, $menuPrices[$itemId]]);
        }

        db()->prepare("UPDATE `bar_tables` SET status = 'occupied' WHERE id = ?")->execute([$table['id']]);

        db()->commit();
        echo json_encode(['success' => true, 'order_id' => $orderId]);
    } catch (Exception $e) {
        db()->rollBack();
        echo json_encode(['success' => false, 'message' => 'Database error.']);
    }
    exit;
}
// View order confirmation
$orderId = (int)($_GET['order_id'] ?? 0);
$token = trim($_GET['token'] ?? '');

// AJAX: return current order status
if (isset($_GET['ajax']) && $_GET['ajax'] === 'status') {
    $statusOrder = fetchOwnedOrder((int)($_GET['order_id'] ?? 0), trim($_GET['token'] ?? ''));
    echo json_encode($statusOrder ? ['status' => $statusOrder['status'], 'paid' => $statusOrder['paid']] : ['status' => 'unknown', 'paid' => 0]);
    exit;
}

$order = fetchOwnedOrder($orderId, $token);

if (!$order) {
    http_response_code(404);
    die('Order not found.');
}

$stmt = db()->prepare("SELECT oi.*, mi.name FROM bar_order_items oi JOIN bar_menu_items mi ON mi.id = oi.menu_item_id WHERE oi.order_id = ?");
$stmt->execute([$orderId]);
$items = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order #<?= $orderId ?> — <?= e(getSetting('bar_name', 'The Bar')) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="/bar/public/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://js.paystack.co/v1/inline.js"></script>
    <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
    </style>
</head>
<body class="bg-gray-50">
    <div class="max-w-sm mx-auto p-4 text-center">
        <?php if ($order['status'] === 'pending'): ?>
        <div class="text-5xl mb-4">🕐</div>
        <h1 class="text-xl font-bold">Order Submitted!</h1>
        <p class="text-gray-500 mb-4">Table <?= $order['table_number'] ?> — Order #<?= $orderId ?></p>
        <p class="text-sm text-gray-500 mb-6">Your order is being reviewed by staff. We'll bring it to you shortly.</p>

        <div class="bg-white rounded-xl p-4 shadow-sm mb-4 text-left">
            <?php foreach ($items as $item): ?>
            <div class="flex justify-between py-1">
                <span><?= e($item['name']) ?> x<?= $item['quantity'] ?></span>
                <span class="font-medium"><?= money($item['quantity'] * $item['unit_price']) ?></span>
            </div>
            <?php endforeach; ?>
            <div class="border-t pt-2 mt-2 flex justify-between font-bold text-lg">
                <span>Total</span><span><?= money($order['total']) ?></span>
            </div>
        </div>

        <?php if (!$order['paid']): ?>
        <p class="text-sm text-gray-500 mb-3">Pay now with card, or pay at the bar.</p>
        <div class="text-left mb-3">
            <label class="text-xs text-gray-500 block mb-1">Email for receipt (optional)</label>
            <input type="email" id="payerEmail" placeholder="you@example.com" class="form-input text-sm">
        </div>
        <button onclick="payWithPaystack(this)" class="btn btn-accent w-full py-3 rounded-full shadow-md text-base">
            <i class="ri-bank-card-line"></i> Pay Now (<?= money($order['total']) ?>)
        </button>
        <p class="text-xs text-gray-400 mt-2">Powered by Paystack</p>
        <?php else:
        $pStmt = db()->prepare("SELECT method FROM bar_payments WHERE order_id = ? ORDER BY id DESC LIMIT 1");
        $pStmt->execute([$orderId]);
        $payMethod = $pStmt->fetchColumn();
        ?>
        <div class="bg-green-50 text-green-700 p-4 rounded-lg font-bold">
            ✓ Paid <?= $payMethod ? '(' . e($payMethod) . ')' : '' ?>
        </div>
        <?php endif; ?>

        <?php elseif ($order['status'] === 'accepted'): ?>
        <div class="text-5xl mb-4">🍳</div>
        <h1 class="text-xl font-bold">Preparing Your Order</h1>
        <p class="text-gray-500">We're working on it!</p>

        <?php elseif ($order['status'] === 'ready'): ?>
        <div class="text-5xl mb-4">✅</div>
        <h1 class="text-xl font-bold">Order Ready!</h1>
        <p class="text-gray-500">Your items are being brought to you.</p>

        <?php elseif ($order['status'] === 'served' || $order['status'] === 'closed'): ?>
        <div class="text-5xl mb-4">🍹</div>
        <h1 class="text-xl font-bold">Enjoy!</h1>
        <p class="text-gray-500 mb-4">Your order has been served.</p>
        <div class="bg-white rounded-xl p-4 shadow-sm mb-4 text-left">
            <?php foreach ($items as $item): ?>
            <div class="flex justify-between py-1">
                <span><?= e($item['name']) ?> x<?= $item['quantity'] ?></span>
                <span><?= money($item['quantity'] * $item['unit_price']) ?></span>
            </div>
            <?php endforeach; ?>
            <div class="border-t pt-2 mt-2 flex justify-between font-bold">
                <span>Total</span><span><?= money($order['total']) ?></span>
            </div>
            <?php if ($order['paid']):
            $pStmt2 = db()->prepare("SELECT method FROM bar_payments WHERE order_id = ? ORDER BY id DESC LIMIT 1");
            $pStmt2->execute([$orderId]);
            $payMethod2 = $pStmt2->fetchColumn();
            ?>
            <div class="text-green-600 font-bold text-center mt-2">✓ Paid via <?= e($payMethod2 ?: 'card') ?></div>
            <?php endif; ?>
        </div>
        <?php endif; ?>

        <a href="/bar/customer/menu.php?token=<?= e($token) ?>" class="btn-outline inline-block mt-4">Back to Menu</a>
    </div>

    <script>
    // Used only when the customer leaves the email field blank — keeps each
    // transaction's email unique per order instead of one fake address reused
    // for every payment, without requiring the customer to enter anything.
    var FALLBACK_PAYER_EMAIL = '<?= e('order-' . $orderId . '@noemail.local') ?>';

    function payWithPaystack(btn) {
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner"></span> Processing...';
        var emailInput = document.getElementById('payerEmail');
        var payerEmail = (emailInput && emailInput.value.trim()) || FALLBACK_PAYER_EMAIL;
        var handler = PaystackPop.setup({
            key: '<?= getenv('PAYSTACK_PUBLIC_KEY') ?: 'pk_test_xxxxxxxx' ?>',
            email: payerEmail,
            amount: <?= round($order['total'] * 100) ?>,
            currency: 'NGN',
            ref: 'BAR-' + Date.now(),
            callback: function(response) {
                window.location.href = '/bar/customer/receipt.php?ref=' + response.reference + '&order_id=<?= $orderId ?>&token=<?= urlencode($token) ?>';
            },
            onClose: function() {
                btn.disabled = false;
                btn.innerHTML = '<i class="ri-bank-card-line"></i> Pay Now (<?= money($order['total']) ?>)';
            }
        });
        handler.openIframe();
    }

    // ── Live order status polling ─────────────────────────────────────────────
    <?php $terminalStatuses = ['served', 'closed']; ?>
    <?php $isTerminal = in_array($order['status'], $terminalStatuses); ?>
    (function() {
        // Only poll for non-terminal statuses
        if (<?= $isTerminal ? 'true' : 'false' ?>) return;

        var STATUS_URL  = '/bar/customer/order.php?ajax=status&order_id=<?= (int)$orderId ?>&token=<?= urlencode($token) ?>';
        var pollTimer   = null;
        var currentStatus = '<?= e($order['status']) ?>';

        var statusConfig = {
            pending:  { icon: '🕐', title: 'Waiting for staff…',     color: 'text-amber-600' },
            accepted: { icon: '🍳', title: 'Preparing your order!',   color: 'text-blue-600'  },
            ready:    { icon: '✅', title: 'Order Ready!',             color: 'text-green-600' },
            served:   { icon: '🍹', title: 'Enjoy!',                  color: 'text-green-600' },
            closed:   { icon: '🍹', title: 'Enjoy!',                  color: 'text-green-600' },
        };

        function updateStatusUI(newStatus) {
            var cfg = statusConfig[newStatus] || statusConfig.pending;
            var iconEl  = document.getElementById('statusIcon');
            var titleEl = document.getElementById('statusTitle');
            var barEl   = document.getElementById('statusBar');
            if (iconEl)  iconEl.textContent  = cfg.icon;
            if (titleEl) { titleEl.textContent = cfg.title; titleEl.className = 'text-xl font-bold ' + cfg.color; }

            // Update progress bar
            var steps = { pending: 1, accepted: 2, ready: 3, served: 4, closed: 4 };
            var step  = steps[newStatus] || 1;
            if (barEl) {
                barEl.querySelectorAll('.step-dot').forEach(function(dot, i) {
                    dot.classList.toggle('bg-amber-500', i < step);
                    dot.classList.toggle('bg-gray-200',  i >= step);
                });
            }
        }

        function poll() {
            fetch(STATUS_URL)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.status && data.status !== currentStatus) {
                        currentStatus = data.status;
                        // Reload page cleanly to show correct UI state
                        window.location.reload();
                    }
                })
                .catch(function() { /* silent fail */ });
        }

        // Poll every 5 seconds
        pollTimer = setInterval(poll, 5000);
    })();
    </script>
</body>
</html>
