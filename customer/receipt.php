<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';

$ref     = trim($_GET['ref']      ?? '');
$orderId = (int)($_GET['order_id'] ?? 0);
$token   = trim($_GET['token']    ?? '');

if (!$ref || !$orderId) {
    http_response_code(400);
    die('Invalid request.');
}

// Ownership check — the table QR token must actually own this order, otherwise
// anyone could view another table's payment status by guessing an order id.
$order = fetchOwnedOrder($orderId, $token);
if (!$order) {
    http_response_code(404);
    die('Order not found.');
}

// ── Idempotency: check if this reference was already processed ────────────────
$dupStmt = db()->prepare("SELECT id FROM bar_payments WHERE reference = ? LIMIT 1");
$dupStmt->execute([$ref]);
$alreadyPaid = (bool)$dupStmt->fetchColumn();

$success = false;

if (!$alreadyPaid) {
    // Verify with Paystack only if not already recorded
    $secret = getenv('PAYSTACK_SECRET_KEY') ?: 'sk_test_xxxxxxxx';
    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL            => "https://api.paystack.co/transaction/verify/" . urlencode($ref),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER     => ["Authorization: Bearer $secret"],
        CURLOPT_TIMEOUT        => 15,
    ]);
    $response = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($response, true);
    $success = !empty($data['status']) && ($data['data']['status'] ?? '') === 'success';

    if ($success) {
        $amount = $data['data']['amount'] / 100;

        db()->beginTransaction();
        try {
            // INSERT IGNORE prevents a race-condition double-insert
            db()->prepare("INSERT IGNORE INTO bar_payments (order_id, amount, method, reference) VALUES (?, ?, 'online', ?)")
                ->execute([$orderId, $amount, $ref]);

            db()->prepare("UPDATE bar_orders SET paid = 1, status = 'closed', closed_at = NOW() WHERE id = ? AND paid = 0")
                ->execute([$orderId]);

            $ord = db()->prepare("SELECT table_id FROM bar_orders WHERE id = ?");
            $ord->execute([$orderId]);
            $orderRow = $ord->fetch();
            if ($orderRow) {
                db()->prepare("UPDATE `bar_tables` SET status = 'free' WHERE id = ?")
                    ->execute([$orderRow['table_id']]);
            }

            db()->commit();
        } catch (Exception $e) {
            db()->rollBack();
        }
    }
} else {
    // Reference already recorded — treat as success (idempotent re-load)
    $success = true;
}

// ── Re-fetch order for display (payment fields above may have just changed it) ─
$order = fetchOwnedOrder($orderId, $token);

$stmt = db()->prepare("
    SELECT oi.*, mi.name
    FROM bar_order_items oi
    JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
    WHERE oi.order_id = ?
");
$stmt->execute([$orderId]);
$items = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment — <?= e(getSetting('bar_name', 'The Bar')) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="/bar/public/css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="min-h-screen bg-gray-50">
    <div class="max-w-sm mx-auto p-4 text-center pt-8">
        <?php if ($success): ?>
        <div class="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-4">
            <i class="ri-check-line text-green-600 text-3xl"></i>
        </div>
        <h1 class="text-xl font-bold text-green-600">Payment Successful!</h1>
        <p class="text-gray-500 text-sm mb-6">Ref: <?= e($ref) ?></p>
        <?php else: ?>
        <div class="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
            <i class="ri-close-line text-red-600 text-3xl"></i>
        </div>
        <h1 class="text-xl font-bold text-red-600">Payment Failed</h1>
        <p class="text-gray-500 text-sm mb-6">Please try again or pay at the bar.</p>
        <?php endif; ?>

        <?php if ($order): ?>
        <div class="card text-left">
            <p class="text-sm text-gray-500 mb-3">Table <?= $order['table_number'] ?> — Order #<?= $orderId ?></p>
            <?php foreach ($items as $item): ?>
            <div class="flex justify-between py-1 text-sm">
                <span><?= e($item['name']) ?> ×<?= $item['quantity'] ?></span>
                <span class="font-medium"><?= money($item['quantity'] * $item['unit_price']) ?></span>
            </div>
            <?php endforeach; ?>
            <?php
            $subtotal = (float)($order['subtotal'] ?: $order['total']);
            $taxAmt   = (float)($order['tax_amount'] ?? 0);
            $grandTotal = (float)$order['total'];
            ?>
            <div class="border-t pt-2 mt-2 space-y-0.5 text-sm">
                <?php if ($taxAmt > 0): ?>
                <div class="flex justify-between text-gray-500">
                    <span>Subtotal</span><span><?= money($subtotal) ?></span>
                </div>
                <div class="flex justify-between text-gray-500">
                    <span>Tax (<?= getTaxRate() ?>%)</span><span><?= money($taxAmt) ?></span>
                </div>
                <?php endif; ?>
                <div class="flex justify-between font-bold text-base pt-1">
                    <span>Total</span><span><?= money($grandTotal) ?></span>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <a href="/bar/customer/menu.php?token=<?= e($token) ?>" class="btn btn-outline mt-4 inline-block">
            <i class="ri-arrow-left-line"></i> Back to Menu
        </a>
    </div>
</body>
</html>
