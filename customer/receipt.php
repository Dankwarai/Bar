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

$order = fetchOwnedOrder($orderId, $token);
if (!$order) {
    http_response_code(404);
    die('Order not found.');
}

$dupStmt = db()->prepare("SELECT id FROM bar_payments WHERE reference = ? LIMIT 1");
$dupStmt->execute([$ref]);
$alreadyPaid = (bool)$dupStmt->fetchColumn();

$success = false;

if (!$alreadyPaid) {
    $secret = getenv('PAYSTACK_SECRET_KEY') ?: 'sk_test_0745d2330a55b1c1f626aba2487e7f3dc08ff6dc';
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
            db()->prepare("INSERT IGNORE INTO bar_payments (order_id, amount, method, reference) VALUES (?, ?, 'online', ?)")
                ->execute([$orderId, $amount, $ref]);

            db()->prepare("UPDATE bar_orders SET paid = 1 WHERE id = ? AND paid = 0")
                ->execute([$orderId]);

            db()->prepare("UPDATE bar_orders SET status = 'accepted' WHERE id = ? AND status = 'pending'")
                ->execute([$orderId]);

            db()->commit();
        } catch (Exception $e) {
            db()->rollBack();
        }
    }
} else {
    $success = true;
}

$order = fetchOwnedOrder($orderId, $token);

$stmt = db()->prepare("
    SELECT oi.*, mi.name
    FROM bar_order_items oi
    JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
    WHERE oi.order_id = ?
");
$stmt->execute([$orderId]);
$items = $stmt->fetchAll();

$discAmount = (float)($order['discount_amount'] ?? 0);
$discType   = $order['discount_type'] ?? 'none';
$discValue  = (float)($order['discount_value'] ?? 0);
$subtotal   = (float)($order['subtotal'] ?: $order['total']) + $discAmount;
$taxAmt     = (float)($order['tax_amount'] ?? 0);
$grandTotal = (float)$order['total'];
$barName    = getSetting('bar_name', 'The Bar');
$now        = date('M j, Y g:i A');

if (!$success) {
    header('Location: /bar/customer/order.php?order_id=' . $orderId . '&token=' . urlencode($token) . '&pay=1');
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt — <?= e($barName) ?></title>
    <link href="/bar/public/vendor/inter/inter.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter Variable', 'Courier New', monospace;
            background: #fff;
            color: #000;
            font-size: 12px;
            line-height: 1.5;
            width: 80mm;
            margin: 0 auto;
            padding: 10px 8px;
        }
        .header { text-align: center; margin-bottom: 12px; }
        .header h1 { font-size: 18px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase; }
        .header p { font-size: 11px; color: #555; }
        .divider { border-top: 1px dashed #999; margin: 8px 0; }
        .thick-divider { border-top: 2px solid #000; margin: 8px 0; }
        .info-row { display: flex; justify-content: space-between; font-size: 11px; }
        .items { width: 100%; border-collapse: collapse; }
        .items th { text-align: left; font-size: 10px; text-transform: uppercase; color: #555; padding-bottom: 4px; }
        .items td { padding: 2px 0; vertical-align: top; }
        .items .qty { text-align: center; width: 30px; }
        .items .price { text-align: right; width: 65px; white-space: nowrap; }
        .totals { margin-top: 4px; }
        .totals .row { display: flex; justify-content: space-between; padding: 2px 0; font-size: 11px; }
        .totals .grand { font-weight: 800; font-size: 14px; border-top: 1px dashed #999; padding-top: 4px; margin-top: 4px; }
        .payment-detail { text-align: center; margin: 10px 0; }
        .payment-detail .badge { display: inline-block; background: #d1fae5; color: #065f46; font-weight: 700; font-size: 11px; padding: 3px 12px; border-radius: 20px; }
        .footer { text-align: center; font-size: 10px; color: #888; margin-top: 10px; }
        .actions { margin-top: 16px; text-align: center; }
        .actions a, .actions button {
            display: inline-block; padding: 8px 20px; margin: 4px; border-radius: 6px;
            font-size: 13px; font-weight: 600; text-decoration: none; cursor: pointer; border: none;
        }
        .btn-print { background: #000; color: #fff; }
        .btn-back { background: #f3f4f6; color: #333; }
        .screen-only { display: block; }
        .receipt-header-img { font-size: 10px; }
        @media print {
            .screen-only { display: none; }
            @page { margin: 0; size: 80mm auto; }
            body { padding: 0; width: 100%; }
        }
    </style>
</head>
<body>

    <div class="screen-only actions">
        <button class="btn-print" onclick="window.print()">🖨 Print Receipt</button>
        <a class="btn-back" href="/bar/customer/order.php?order_id=<?= $orderId ?>&token=<?= e($token) ?>">← Back</a>
    </div>

    <div class="header">
        <h1><?= e($barName) ?></h1>
        <p>📍 Table <?= e($order['table_number']) ?> • Order #<?= $orderId ?></p>
        <p><?= $now ?></p>
    </div>

    <div class="thick-divider"></div>

    <div class="info-row"><span>Reference</span><span><?= e($ref) ?></span></div>
    <div class="info-row"><span>Status</span><span>Paid ✓</span></div>

    <div class="thick-divider"></div>

    <table class="items">
        <thead>
            <tr><th>Item</th><th class="qty">Qty</th><th class="price">Amount</th></tr>
        </thead>
        <tbody>
            <?php foreach ($items as $item): ?>
            <tr>
                <td><?= e($item['name']) ?></td>
                <td class="qty"><?= (int)$item['quantity'] ?></td>
                <td class="price"><?= money($item['quantity'] * $item['unit_price']) ?></td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <div class="totals">
        <?php if ($taxAmt > 0 || $discAmount > 0): ?>
        <div class="row"><span>Subtotal</span><span><?= money($subtotal) ?></span></div>
        <?php endif; ?>
        <?php if ($discAmount > 0): ?>
        <div class="row" style="color:#16a34a;"><span>Discount <?= $discType === 'percent' ? "({$discValue}%)" : '' ?></span><span>−<?= money($discAmount) ?></span></div>
        <?php endif; ?>
        <?php if ($taxAmt > 0): ?>
        <div class="row"><span>Tax (<?= getTaxRate() ?>%)</span><span><?= money($taxAmt) ?></span></div>
        <?php endif; ?>
        <div class="row grand"><span>Total Paid</span><span><?= money($grandTotal) ?></span></div>
    </div>

    <div class="payment-detail">
        <span class="badge">✓ PAID — Online</span>
    </div>

    <div class="divider"></div>

    <div class="footer">
        <p>Thank you for your order!</p>
        <p style="margin-top:4px;">Your order is being prepared.</p>
    </div>

    <div class="screen-only actions">
        <button class="btn-print" onclick="window.print()">🖨 Print Receipt</button>
        <a class="btn-back" href="/bar/customer/order.php?order_id=<?= $orderId ?>&token=<?= e($token) ?>">← Back to Order</a>
    </div>

    <script>
        if (window.location.search.includes('print=1')) {
            window.addEventListener('load', function() { setTimeout(function() { window.print(); }, 500); });
        }
    </script>
</body>
</html>

