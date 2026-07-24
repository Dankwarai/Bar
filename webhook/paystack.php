<?php
/**
 * Paystack Webhook Handler
 * Called by Paystack when a payment event occurs.
 * Verify the event signature before processing.
 */

require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';

$input = file_get_contents('php://input');
$event = json_decode($input, true);

if (!$event || !isset($event['event'])) {
    http_response_code(400);
    exit('Invalid event');
}

// Verify signature
$secret = getenv('PAYSTACK_SECRET_KEY') ?: 'sk_test_xxxxxxxx';
$signature = $_SERVER['HTTP_X_PAYSTACK_SIGNATURE'] ?? '';
if ($signature !== hash_hmac('sha512', $input, $secret)) {
    http_response_code(401);
    exit('Invalid signature');
}

// Handle charge.success
if ($event['event'] === 'charge.success') {
    $data = $event['data'];
    $reference = $data['reference'];
    $amount = $data['amount'] / 100;
    $orderRef = $data['metadata']['order_id'] ?? null;

    // Idempotency: Paystack retries webhook deliveries, so the same event can arrive more
    // than once. This check skips the obvious repeat; the bar_payments.reference UNIQUE
    // index is the authoritative guard for two near-simultaneous deliveries racing each other.
    $dupStmt = db()->prepare("SELECT id FROM bar_payments WHERE reference = ? LIMIT 1");
    $dupStmt->execute([$reference]);
    $alreadyRecorded = (bool)$dupStmt->fetchColumn();

    if ($orderRef && !$alreadyRecorded) {
        $stmt = db()->prepare("SELECT id FROM bar_orders WHERE id = ? AND paid = 0");
        $stmt->execute([$orderRef]);
        $order = $stmt->fetch();

        if ($order) {
            db()->beginTransaction();
            try {
                $stmt = db()->prepare("INSERT INTO bar_payments (order_id, amount, method, reference) VALUES (?, ?, 'online', ?)");
                $stmt->execute([$order['id'], $amount, $reference]);

                $stmt = db()->prepare("UPDATE bar_orders SET paid = 1, status = 'closed', closed_at = NOW() WHERE id = ?");
                $stmt->execute([$order['id']]);

                $stmt = db()->prepare("SELECT table_id FROM bar_orders WHERE id = ?");
                $stmt->execute([$order['id']]);
                $o = $stmt->fetch();
                if ($o) {
                    db()->prepare("UPDATE `bar_tables` SET status = 'free' WHERE id = ?")->execute([$o['table_id']]);
                }

                db()->commit();
            } catch (Exception $e) {
                // Most likely a duplicate reference from a near-simultaneous retry, caught by
                // the UNIQUE index — the other delivery already recorded it. Log in case it's
                // something else, but a webhook has no user to show an error to.
                db()->rollBack();
                error_log('paystack webhook: ' . $e->getMessage());
            }
        }
    }
}

http_response_code(200);
echo 'OK';
