<?php
require_once __DIR__ . '/db.php';

// ── Output escaping ──────────────────────────────────────────────────────────
function e($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

// ── Money formatting ─────────────────────────────────────────────────────────
function money($amount): string {
    return '₦' . number_format((float)$amount, 2);
}

// ── Settings ─────────────────────────────────────────────────────────────────
function getSetting(string $key, string $default = ''): string {
    static $cache = [];
    if (!isset($cache[$key])) {
        $stmt = db()->prepare("SELECT `value` FROM bar_settings WHERE `key` = ?");
        $stmt->execute([$key]);
        $row = $stmt->fetch();
        $cache[$key] = $row ? $row['value'] : $default;
    }
    return $cache[$key];
}

// ── Tax helpers ───────────────────────────────────────────────────────────────
function getTaxRate(): float {
    return max(0.0, (float)getSetting('tax_rate', '0'));
}

// $rate overrides the configured tax rate when given — lets the math be unit
// tested without a database; production call sites all omit it and get the
// real configured rate via getSetting().
function calcTax(float $subtotal, ?float $rate = null): float {
    $rate = $rate ?? getTaxRate();
    return $rate > 0 ? round($subtotal * $rate / 100, 2) : 0.0;
}

function calcTotal(float $subtotal, ?float $rate = null): float {
    return $subtotal + calcTax($subtotal, $rate);
}

// ── CSRF protection ───────────────────────────────────────────────────────────
/**
 * Generate (or retrieve existing) CSRF token for this session.
 */
function csrfToken(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Render a hidden CSRF input field. Drop <?= csrfField() ?> into every form.
 */
function csrfField(): string {
    return '<input type="hidden" name="_csrf" value="' . csrfToken() . '">';
}

/**
 * Verify the CSRF token on POST. Dies with 403 if invalid.
 */
function verifyCsrf(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') return;
    $token = $_POST['_csrf'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!hash_equals(csrfToken(), $token)) {
        http_response_code(403);
        die('Invalid or missing CSRF token.');
    }
}

// ── Audit log ─────────────────────────────────────────────────────────────────
/**
 * Write an entry to bar_audit_log.
 * $action  — short code e.g. 'checkout', 'void_order', 'stock_adjust'
 * $target  — what was affected e.g. 'order #42'
 * $details — any extra context (optional)
 */
function auditLog(string $action, string $target = '', string $details = ''): void {
    try {
        $stmt = db()->prepare("
            INSERT INTO bar_audit_log (user_id, user_name, action, target, details, ip)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $_SESSION['user_id']   ?? null,
            $_SESSION['user_name'] ?? 'system',
            $action,
            $target,
            $details,
            $_SERVER['REMOTE_ADDR'] ?? '',
        ]);
    } catch (Throwable $e) {
        // Audit failure should never break a business operation — fail silently
        error_log('auditLog failed: ' . $e->getMessage());
    }
}

// ── Refunds ───────────────────────────────────────────────────────────────────
/**
 * Amount still refundable on an order: total paid minus total already refunded.
 */
function remainingRefundable(int $orderId): float {
    $stmt = db()->prepare("SELECT COALESCE(SUM(amount), 0) FROM bar_payments WHERE order_id = ?");
    $stmt->execute([$orderId]);
    $paid = (float)$stmt->fetchColumn();

    $stmt = db()->prepare("SELECT COALESCE(SUM(amount), 0) FROM bar_refunds WHERE order_id = ?");
    $stmt->execute([$orderId]);
    $refunded = (float)$stmt->fetchColumn();

    return max(0.0, round($paid - $refunded, 2));
}

// ── Customer-facing order ownership ───────────────────────────────────────────
/**
 * Fetch a customer-facing order only if the given table QR token actually owns it.
 * Returns null if the order doesn't exist OR the token doesn't match its table —
 * both cases are treated identically so a wrong token can't be used to probe
 * whether a given order id exists.
 */
function fetchOwnedOrder(int $orderId, string $token): ?array {
    if ($orderId <= 0 || $token === '') return null;
    $stmt = db()->prepare("
        SELECT o.*, t.number AS table_number
        FROM bar_orders o
        JOIN `bar_tables` t ON t.id = o.table_id
        WHERE o.id = ? AND t.qr_token = ?
    ");
    $stmt->execute([$orderId, $token]);
    $order = $stmt->fetch();
    return $order ?: null;
}

// ── Stock availability ────────────────────────────────────────────────────────
/**
 * Whether a menu item is currently sellable based on linked inventory.
 * Mirrors the MIN(quantity) <= 0 rule used for the POS "out of stock" badge.
 * Items with no inventory mapping are always sellable (unlimited).
 */
function isMenuItemOutOfStock(int $menuItemId): bool {
    $stmt = db()->prepare("
        SELECT COUNT(*) AS total, SUM(CASE WHEN inv.quantity <= 0 THEN 1 ELSE 0 END) AS out_of_stock
        FROM bar_menu_inventory bmi
        JOIN bar_inventory inv ON inv.id = bmi.inventory_id
        WHERE bmi.menu_item_id = ?
    ");
    $stmt->execute([$menuItemId]);
    $row = $stmt->fetch();
    return (int)($row['total'] ?? 0) > 0 && (int)($row['out_of_stock'] ?? 0) > 0;
}

// ── Inventory → Menu item availability sync ───────────────────────────────────
/**
 * After any stock change on $inventoryId, check all menu items linked to it.
 * Deactivate the menu item if any linked stock is at zero.
 * Reactivate it if all linked stock is above zero.
 */
function syncMenuItemAvailability(int $inventoryId): void {
    $stmt = db()->prepare("SELECT menu_item_id FROM bar_menu_inventory WHERE inventory_id = ?");
    $stmt->execute([$inventoryId]);
    $menuItemIds = $stmt->fetchAll(PDO::FETCH_COLUMN);

    foreach ($menuItemIds as $menuItemId) {
        $checkStmt = db()->prepare("
            SELECT COUNT(*) AS total,
                   SUM(CASE WHEN inv.quantity <= 0 THEN 1 ELSE 0 END) AS out_of_stock
            FROM bar_menu_inventory bmi
            JOIN bar_inventory inv ON inv.id = bmi.inventory_id
            WHERE bmi.menu_item_id = ?
        ");
        $checkStmt->execute([$menuItemId]);
        $row = $checkStmt->fetch();

        $shouldBeActive = ((int)$row['out_of_stock'] === 0) ? 1 : 0;

        $curStmt = db()->prepare("SELECT active, name FROM bar_menu_items WHERE id = ?");
        $curStmt->execute([$menuItemId]);
        $cur = $curStmt->fetch();
        if (!$cur) continue;

        if ((int)$cur['active'] !== $shouldBeActive) {
            db()->prepare("UPDATE bar_menu_items SET active = ? WHERE id = ?")
                ->execute([$shouldBeActive, $menuItemId]);
            $state = $shouldBeActive ? 'reactivated (stock restored)' : 'deactivated (out of stock)';
            auditLog('auto_stock_sync', "menu item #{$menuItemId}", "{$cur['name']} {$state}");
        }
    }
}

// ── Order payment method schema guard ─────────────────────────────────────────
function ensureOrderPaymentMethodColumn(): void {
    static $done = false;
    if ($done) return;
    try {
        $column = db()->query("SHOW COLUMNS FROM bar_orders LIKE 'payment_method'")->fetch();
        if (!$column) {
            db()->exec("ALTER TABLE bar_orders ADD COLUMN payment_method ENUM('cash', 'pos', 'card', 'online') NOT NULL DEFAULT 'cash' AFTER customer_session");
        }
    } catch (Throwable $e) {
        error_log('ensureOrderPaymentMethodColumn failed: ' . $e->getMessage());
    }
    $done = true;
}

function paymentMethodLabel(?string $method): string {
    $labels = [
        'cash' => 'Cash',
        'pos' => 'POS',
        'card' => 'Card',
        'online' => 'Online',
    ];
    $key = $method ?: 'cash';
    return isset($labels[$key]) ? $labels[$key] : 'Cash';
}

// ── Quick stat helpers (used by dashboard) ────────────────────────────────────
function activeOrdersCount(): int {
    $stmt = db()->prepare("SELECT COUNT(*) FROM bar_orders WHERE status NOT IN ('closed')");
    $stmt->execute();
    return (int)$stmt->fetchColumn();
}

function todaySales(): float {
    $stmt = db()->prepare("SELECT COALESCE(SUM(amount), 0) FROM bar_payments WHERE DATE(created_at) = CURDATE()");
    $stmt->execute();
    return (float)$stmt->fetchColumn();
}
