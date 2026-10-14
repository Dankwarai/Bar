<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$action = $_POST['action'] ?? '';
$msg = '';
$msgType = 'success';
if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

require __DIR__ . '/../includes/table_actions.php';

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$tables = db()->query("SELECT * FROM `bar_tables` ORDER BY active DESC, number")->fetchAll();
$barName = getSetting('bar_name', 'The Bar');
$barAddress = getSetting('bar_address', '');
$qrMessage = getSetting('qr_message', 'Scan. Order. Sip. Repeat.');
$baseUrl = rtrim(getSetting('bar_url', (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . dirname(dirname($_SERVER['SCRIPT_NAME']))), '/');
$msg = $_GET['msg'] ?? '';

$activeCount = 0;
foreach ($tables as $t) { if ($t['active']) $activeCount++; }
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-qr-code-line text-amber-500 mr-1"></i> QR Codes</h2>
        <div class="flex flex-wrap gap-2">
            <button onclick="document.getElementById('addTableModal').classList.remove('hidden')" class="btn btn-primary btn-sm"><i class="ri-add-line"></i> Add Table</button>
            <button onclick="window.print()" class="btn btn-outline btn-sm"><i class="ri-printer-line"></i> Print Sheet</button>
        </div>
    </div>

    <?php if ($msg === 'added'): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-checkbox-circle-fill"></i> Table added with auto-generated QR token.
    </div>
    <?php elseif ($msg === 'edited'): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-checkbox-circle-fill"></i> Table updated.
    </div>
    <?php elseif ($msg === 'regenerated'): ?>
    <div class="flex items-center gap-2 bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-information-fill"></i> Token regenerated. Print new QR codes.
    </div>
    <?php endif; ?>

    <!-- Stats -->
    <div class="stats-grid mb-6">
        <div class="stat-card">
            <div class="stat-value"><?= $activeCount ?>/<?= count($tables) ?></div>
            <div class="stat-label">Active Tables</div>
            <i class="ri-table-line stat-icon"></i>
        </div>
        <div class="stat-card">
            <div class="stat-value"><?= count($tables) ?></div>
            <div class="stat-label">Total Tables</div>
            <i class="ri-grid-line stat-icon"></i>
        </div>
        <div class="stat-card">
            <div class="stat-value"><?= $activeCount > 0 ? 'Ready' : 'None' ?></div>
            <div class="stat-label">QR Status</div>
            <i class="ri-qr-code-line stat-icon"></i>
        </div>
    </div>

    <?php if (!$tables): ?>
    <div class="empty-state card">
        <i class="ri-qr-code-line"></i>
        <p class="font-medium text-gray-700">No tables yet</p>
        <p class="text-sm mt-1">Add your first table to generate QR codes</p>
        <button onclick="document.getElementById('addTableModal').classList.remove('hidden')" class="btn btn-primary mt-4 btn-sm">Add Table</button>
    </div>
    <?php endif; ?>

    <!-- QR Code Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4" id="qrGrid">
        <?php foreach ($tables as $t):
            $tableUrl = $baseUrl . '/customer/menu.php?token=' . $t['qr_token'];
            $statusBadge = match($t['status']) {
                'free' => 'badge-ready',
                'occupied' => 'badge-accepted',
                'reserved' => 'badge-pending',
                default => 'badge-closed',
            };
        ?>
        <div class="card text-center <?= $t['active'] ? '' : 'opacity-50' ?> qr-table-card" data-id="<?= $t['id'] ?>">
            <!-- Header -->
            <div class="flex items-center justify-between mb-2">
                <span class="badge <?= $statusBadge ?> text-xs"><?= e($t['status']) ?></span>
                <span class="badge <?= $t['active'] ? 'badge-ready' : 'badge-closed' ?> text-xs">
                    <i class="ri-<?= $t['active'] ? 'checkbox-circle' : 'close-circle' ?>-line"></i>
                    <?= $t['active'] ? 'Active' : 'Inactive' ?>
                </span>
            </div>
            <div class="mb-1">
                <div class="font-bold text-sm text-gray-500">TABLE</div>
                <div class="text-3xl font-black"><?= $t['number'] ?></div>
                <div class="text-xs text-gray-400"><?= $t['capacity'] ?> seat<?= $t['capacity'] !== 1 ? 's' : '' ?></div>
            </div>
            <div class="flex justify-center mb-3">
                <div id="qrcode_<?= $t['id'] ?>" class="bg-white rounded-xl p-2 border shadow-sm" style="width:130px;height:130px;"></div>
            </div>
            <p class="text-xs text-gray-400 mb-3"><?= e($barName) ?></p>

            <!-- Token row -->
            <div class="flex items-center justify-center gap-1 mb-3 bg-gray-50 rounded-lg px-2 py-1.5 mx-1">
                <code class="text-xs font-mono text-gray-500 truncate"><?= e(substr($t['qr_token'], 0, 14)) ?>…</code>
                <button onclick="copyText('<?= e($t['qr_token']) ?>', this)" class="btn btn-ghost btn-xs text-gray-400 hover:text-blue-600 flex-shrink-0" title="Copy token">
                    <i class="ri-file-copy-line"></i>
                </button>
            </div>

            <!-- Actions -->
            <div class="flex flex-wrap gap-1.5 justify-center">
                <button onclick="downloadQR(<?= $t['id'] ?>, <?= $t['number'] ?>)" class="btn btn-sm btn-primary text-xs">
                    <i class="ri-download-2-line"></i> Download
                </button>
                <button onclick="copyLink('<?= e($tableUrl) ?>', this)" class="btn btn-sm btn-outline text-xs">
                    <i class="ri-link"></i> Copy
                </button>
                <button onclick="openEditModal(<?= $t['id'] ?>, <?= $t['number'] ?>, <?= $t['capacity'] ?>)" class="btn btn-sm btn-ghost text-xs text-blue-600">
                    <i class="ri-pencil-line"></i> Edit
                </button>
                <form method="POST" class="inline" onsubmit="return confirmFormSubmit(event, 'Regenerate QR for Table <?= $t['number'] ?>?')">
                    <?= csrfField() ?>
                    <input type="hidden" name="action" value="regenerate_token">
                    <input type="hidden" name="id" value="<?= $t['id'] ?>">
                    <button type="submit" class="btn btn-sm btn-ghost text-xs text-amber-600">
                        <i class="ri-refresh-line"></i> New Token
                    </button>
                </form>
                <form method="POST" class="inline">
                    <?= csrfField() ?>
                    <input type="hidden" name="action" value="toggle_table">
                    <input type="hidden" name="id" value="<?= $t['id'] ?>">
                    <button type="submit" class="btn btn-sm btn-ghost text-xs <?= $t['active'] ? 'text-red-500' : 'text-green-600' ?>">
                        <i class="ri-<?= $t['active'] ? 'close' : 'check' ?>-line"></i> <?= $t['active'] ? 'Deactivate' : 'Activate' ?>
                    </button>
                </form>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <!-- Print Sheet (hidden on screen, visible when printing) -->
    <div id="qrPrintSheet" class="print-only" style="width:210mm;margin:auto;">
        <div class="text-center mb-6">
            <h1 class="text-2xl font-bold"><?= e($barName) ?></h1>
            <p class="text-lg italic text-gray-600 mt-2">"<?= e($qrMessage) ?>"</p>
        </div>
        <div class="grid grid-cols-4 gap-4">
            <?php foreach ($tables as $t):
                if (!$t['active']) continue;
                $tableUrl = $baseUrl . '/customer/menu.php?token=' . $t['qr_token'];
            ?>
            <div class="border rounded-lg p-4 text-center">
                <div id="print_qr_<?= $t['id'] ?>" class="mb-2 flex justify-center"></div>
                <p class="font-bold text-sm">Table <?= $t['number'] ?></p>
                <p class="text-xs text-gray-500"><?= e($barName) ?></p>
            </div>
            <?php endforeach; ?>
        </div>
        <div class="text-center mt-8 text-sm text-gray-500">
            <p><?= e($barAddress) ?></p>
            <p class="mt-2 italic">Cheers — The Management</p>
        </div>
    </div>
</div>

<!-- Add Table Modal -->
<div id="addTableModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-add-box-line mr-1"></i> Add Table</h3>
            <button type="button" onclick="document.getElementById('addTableModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="add_table">
            <?= csrfField() ?>
            <div class="space-y-3">
                <div><label class="form-label">Table Number <span class="text-red-500">*</span></label><input type="number" name="number" placeholder="e.g. 1" class="form-input" required></div>
                <div><label class="form-label">Capacity (seats) <span class="text-red-500">*</span></label><input type="number" name="capacity" placeholder="e.g. 4" class="form-input" value="2" required></div>
                <p class="text-xs text-gray-400">A unique QR token will be auto-generated.</p>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Add Table</button>
                <button type="button" onclick="document.getElementById('addTableModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Table Modal -->
<div id="editTableModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-pencil-line mr-1"></i> Edit Table</h3>
            <button type="button" onclick="document.getElementById('editTableModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="edit_table">
            <input type="hidden" name="id" id="edit_id" value="">
            <?= csrfField() ?>
            <div class="space-y-3">
                <div><label class="form-label">Table Number <span class="text-red-500">*</span></label><input type="number" name="number" id="edit_number" placeholder="e.g. 1" class="form-input" required></div>
                <div><label class="form-label">Capacity (seats) <span class="text-red-500">*</span></label><input type="number" name="capacity" id="edit_capacity" placeholder="e.g. 4" class="form-input" required></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Save Changes</button>
                <button type="button" onclick="document.getElementById('editTableModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
<script>
// ── Render QR for each table card (screen) ──────────────────────────────────
<?php foreach ($tables as $t):
    $tableUrl = $baseUrl . '/customer/menu.php?token=' . $t['qr_token'];
?>
new QRCode(document.getElementById('qrcode_<?= $t['id'] ?>'), {
    text: '<?= e($tableUrl) ?>',
    width: 110,
    height: 110,
});
new QRCode(document.getElementById('print_qr_<?= $t['id'] ?>'), {
    text: '<?= e($tableUrl) ?>',
    width: 110,
    height: 110,
});
<?php endforeach; ?>

// ── Download individual QR ───────────────────────────────────────────────────
function downloadQR(tableId, tableNumber) {
    var el = document.getElementById('qrcode_' + tableId);
    var canvas = el.querySelector('canvas');
    if (!canvas) return swalAlert('QR not rendered yet.', 'warning');
    var link = document.createElement('a');
    link.download = 'Table_' + tableNumber + '_QR.png';
    link.href = canvas.toDataURL('image/png');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function copyLink(url, btn) {
    navigator.clipboard.writeText(url).then(function() {
        var orig = btn.innerHTML;
        btn.innerHTML = '<i class="ri-check-line"></i> Copied!';
        setTimeout(function() { btn.innerHTML = orig; }, 2000);
    }).catch(function() {
        prompt('Copy this link:', url);
    });
}

function copyText(text, btn) {
    navigator.clipboard.writeText(text).then(function() {
        var orig = btn.innerHTML;
        btn.innerHTML = '<i class="ri-check-line"></i>';
        setTimeout(function() { btn.innerHTML = orig; }, 1500);
    }).catch(function() {
        prompt('Copy this manually:', text);
    });
}

function openEditModal(id, number, capacity) {
    document.getElementById('edit_id').value = id;
    document.getElementById('edit_number').value = number;
    document.getElementById('edit_capacity').value = capacity;
    document.getElementById('editTableModal').classList.remove('hidden');
}
</script>

<style>
@media screen {
    #qrPrintSheet { display: none; }
}
@media print {
    body * { visibility: hidden; }
    #qrPrintSheet, #qrPrintSheet * { visibility: visible; }
    #qrPrintSheet { display: block !important; position: absolute; left: 0; top: 0; }
    #qrGrid, .page-header, .stats-grid, .flex.items-center, .btn-outline, .btn-primary { display: none !important; }
    @page { size: A4; margin: 10mm; }
}
</style>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>