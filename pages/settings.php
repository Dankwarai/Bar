<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin');
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$success = '';
$error   = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verifyCsrf();
    $fields = ['bar_name', 'bar_address', 'bar_url', 'tax_rate', 'receipt_footer', 'qr_message'];
    try {
        $stmt = db()->prepare("INSERT INTO bar_settings (`key`, `value`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)");
        foreach ($fields as $field) {
            $value = trim($_POST[$field] ?? '');
            if ($field === 'tax_rate') {
                $value = max(0, min(100, (float)$value));
            }
            $stmt->execute([$field, $value]);
        }
        $success = 'Settings saved successfully.';
        // Clear getSetting() cache by resetting static
        // (next request will re-read from DB)
    } catch (Exception $e) {
        $error = 'Failed to save settings: ' . $e->getMessage();
    }
}

// Current values
$settings = [];
$rows = db()->query("SELECT `key`, `value` FROM bar_settings")->fetchAll();
foreach ($rows as $row) {
    $settings[$row['key']] = $row['value'];
}
$g = fn(string $key, string $default = '') => $settings[$key] ?? $default;
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-settings-3-line text-amber-500 mr-1"></i> Settings</h2>
    </div>

    <?php if ($success): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-checkbox-circle-fill text-green-500"></i> <?= e($success) ?>
    </div>
    <?php endif; ?>
    <?php if ($error): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> <?= e($error) ?>
    </div>
    <?php endif; ?>

    <form method="POST" class="space-y-6 max-w-2xl">
        <?= csrfField() ?>
        <!-- Bar Identity -->
        <div class="card">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
                <span class="w-7 h-7 rounded-lg bg-amber-100 flex items-center justify-center text-amber-600 text-sm"><i class="ri-store-2-line"></i></span>
                Bar Identity
            </h3>
            <div class="space-y-4">
                <div class="form-group">
                    <label class="form-label">Bar Name</label>
                    <input type="text" name="bar_name" class="form-input" value="<?= e($g('bar_name', 'The Bar')) ?>" required maxlength="100">
                    <p class="text-xs text-gray-400 mt-1">Appears on receipts, login page, and browser title.</p>
                </div>
                <div class="form-group mb-0">
                    <label class="form-label">Address</label>
                    <input type="text" name="bar_address" class="form-input" value="<?= e($g('bar_address')) ?>" maxlength="255" placeholder="123 Main Street, City">
                    <p class="text-xs text-gray-400 mt-1">Printed on thermal receipts below the bar name.</p>
                </div>
                <div class="form-group mb-0">
                    <label class="form-label">Public URL</label>
                    <input type="url" name="bar_url" class="form-input" value="<?= e($g('bar_url')) ?>" maxlength="255" placeholder="http://192.168.1.100/bar">
                    <p class="text-xs text-gray-400 mt-1">
                        Used in QR codes so phones can reach this server.
                        Set to your LAN IP (e.g. <code class="bg-gray-100 px-1 rounded">http://192.168.1.100/bar</code>) or your public domain.
                        Leave blank to auto-detect.
                    </p>
                </div>
            </div>
        </div>

        <!-- Billing -->
        <div class="card">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
                <span class="w-7 h-7 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600 text-sm"><i class="ri-percent-line"></i></span>
                Billing
            </h3>
            <div class="form-group mb-0">
                <label class="form-label">Tax Rate (%)</label>
                <div class="relative">
                    <input type="number" name="tax_rate" class="form-input pr-10" value="<?= e($g('tax_rate', '0')) ?>" min="0" max="100" step="0.01" placeholder="0">
                    <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm font-medium">%</span>
                </div>
                <p class="text-xs text-gray-400 mt-1">Set to 0 to disable tax on receipts.</p>
            </div>
        </div>

        <!-- Receipt & QR -->
        <div class="card">
            <h3 class="font-semibold mb-4 flex items-center gap-2">
                <span class="w-7 h-7 rounded-lg bg-purple-100 flex items-center justify-center text-purple-600 text-sm"><i class="ri-printer-line"></i></span>
                Receipt & QR
            </h3>
            <div class="space-y-4">
                <div class="form-group">
                    <label class="form-label">Receipt Footer Message</label>
                    <textarea name="receipt_footer" class="form-textarea" maxlength="200" placeholder="Thank you for your patronage!"><?= e($g('receipt_footer', 'Thank you for your patronage!')) ?></textarea>
                    <p class="text-xs text-gray-400 mt-1">Printed at the bottom of every receipt (max 200 characters).</p>
                </div>
                <div class="form-group mb-0">
                    <label class="form-label">QR Code Message</label>
                    <input type="text" name="qr_message" class="form-input" value="<?= e($g('qr_message', 'Scan. Order. Sip. Repeat.')) ?>" maxlength="150" placeholder="Scan. Order. Sip. Repeat.">
                    <p class="text-xs text-gray-400 mt-1">Tagline shown on the printed QR code sheet.</p>
                </div>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <button type="submit" class="btn btn-primary">
                <i class="ri-save-line"></i> Save Settings
            </button>
            <span class="text-xs text-gray-400">Changes take effect immediately.</span>
        </div>
    </form>
</div>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
