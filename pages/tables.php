<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$action = $_POST['action'] ?? '';
$msg = ''; $msgType = 'success';
if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

require __DIR__ . '/../includes/table_actions.php';

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$tables = db()->query("SELECT * FROM `bar_tables` ORDER BY number")->fetchAll();
$barName = getSetting('bar_name', 'The Bar');
$baseUrl = rtrim(getSetting('bar_url', (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . dirname(dirname($_SERVER['SCRIPT_NAME']))), '/');
$msg = $_GET['msg'] ?? '';

$activeCount = 0; $totalCapacity = 0; $occupiedCount = 0;
foreach ($tables as $t) {
    if ($t['active']) $activeCount++;
    if ($t['active']) $totalCapacity += $t['capacity'];
    if ($t['status'] === 'occupied') $occupiedCount++;
}
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-table-line text-amber-500 mr-1"></i> Tables</h2>
        <button onclick="document.getElementById('addTableModal').classList.remove('hidden')" class="btn btn-primary btn-sm"><i class="ri-add-line"></i> Add Table</button>
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
        <i class="ri-information-fill"></i> QR token regenerated. Print new QR codes.
    </div>
    <?php endif; ?>

    <?php if ($tables): ?>
    <!-- Stats -->
    <div class="stats-grid mb-6">
        <div class="stat-card">
            <div class="stat-value"><?= $activeCount ?>/<?= count($tables) ?></div>
            <div class="stat-label">Active Tables</div>
            <i class="ri-table-line stat-icon"></i>
        </div>
        <div class="stat-card">
            <div class="stat-value"><?= $totalCapacity ?></div>
            <div class="stat-label">Total Seats</div>
            <i class="ri-group-line stat-icon"></i>
        </div>
        <div class="stat-card <?= $occupiedCount > 0 ? 'border-amber-500' : '' ?>">
            <div class="stat-value <?= $occupiedCount > 0 ? 'text-amber-600' : '' ?>"><?= $occupiedCount ?></div>
            <div class="stat-label">Occupied</div>
            <i class="ri-user-follow-line stat-icon"></i>
        </div>
    </div>

    <!-- Table Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <?php foreach ($tables as $t):
            $tableUrl = e($baseUrl . '/customer/menu.php?token=' . $t['qr_token']);
            $statusColor = match($t['status']) {
                'free' => 'badge-ready',
                'occupied' => 'badge-accepted',
                'reserved' => 'badge-pending',
                default => 'badge-closed',
            };
        ?>
        <div class="card <?= $t['active'] ? '' : 'opacity-50' ?> table-card" data-id="<?= $t['id'] ?>">
            <!-- Header -->
            <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-2.5">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br <?= $t['status'] === 'free' ? 'from-green-100 to-green-200 text-green-600' : 'from-amber-100 to-amber-200 text-amber-600' ?> flex items-center justify-center font-bold text-lg">
                        <?= $t['number'] ?>
                    </div>
                    <div>
                        <h4 class="font-semibold">Table <?= $t['number'] ?></h4>
                        <p class="text-xs text-gray-400"><i class="ri-group-line"></i> <?= $t['capacity'] ?> seat<?= $t['capacity'] !== 1 ? 's' : '' ?></p>
                    </div>
                </div>
                <span class="badge <?= $statusColor ?> text-xs"><?= e($t['status']) ?></span>
            </div>

            <!-- QR Code + Token -->
            <div class="flex gap-3 mb-3">
                <div id="qr_<?= $t['id'] ?>" class="flex-shrink-0 bg-white rounded-lg p-1 border shadow-sm" style="width:90px;height:90px;"></div>
                <div class="flex-1 min-w-0">
                    <div class="text-xs text-gray-400 mb-1">Token</div>
                    <div class="flex items-center gap-1 mb-1">
                        <code class="text-xs font-mono bg-gray-100 px-1.5 py-0.5 rounded truncate block flex-1"><?= e(substr($t['qr_token'], 0, 12)) ?>…</code>
                        <button onclick="copyText('<?= e($t['qr_token']) ?>', this)" class="btn btn-ghost btn-xs text-gray-500 hover:text-blue-600" title="Copy token">
                            <i class="ri-file-copy-line"></i>
                        </button>
                    </div>
                    <div class="text-xs text-gray-400 truncate" title="<?= $tableUrl ?>">
                        <i class="ri-link"></i>
                        <span class="text-xs"><?= e(substr($tableUrl, 0, 35)) ?>…</span>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="grid grid-cols-2 gap-1.5">
                <button onclick="downloadQR(<?= $t['id'] ?>, <?= $t['number'] ?>)" class="btn btn-ghost btn-sm text-green-600 hover:text-green-800">
                    <i class="ri-download-2-line"></i> Download QR
                </button>
                <button onclick="copyLink('<?= $tableUrl ?>', this)" class="btn btn-ghost btn-sm text-blue-600 hover:text-blue-800">
                    <i class="ri-link"></i> Copy Link
                </button>
                <button onclick="openEditModal(<?= $t['id'] ?>, <?= $t['number'] ?>, <?= $t['capacity'] ?>)" class="btn btn-ghost btn-sm text-gray-600 hover:text-blue-600">
                    <i class="ri-pencil-line"></i> Edit
                </button>
                <form method="POST" class="contents">
                    <input type="hidden" name="action" value="regenerate_token">
                    <?= csrfField() ?>
                    <input type="hidden" name="id" value="<?= $t['id'] ?>">
                    <button type="submit" onclick="return confirmRegen(<?= $t['number'] ?>)" class="btn btn-ghost btn-sm text-amber-600 hover:text-amber-800">
                        <i class="ri-refresh-line"></i> Regenerate
                    </button>
                </form>
                <a href="<?= $tableUrl ?>" target="_blank" class="btn btn-ghost btn-sm text-purple-600 hover:text-purple-800 text-center">
                    <i class="ri-eye-line"></i> View Menu
                </a>
                <?php if (in_array($t['status'], ['free', 'reserved'], true)): ?>
                <form method="POST" class="contents">
                    <input type="hidden" name="action" value="toggle_reserved">
                    <?= csrfField() ?>
                    <input type="hidden" name="id" value="<?= $t['id'] ?>">
                    <button type="submit" class="btn btn-ghost btn-sm <?= $t['status'] === 'reserved' ? 'text-blue-600' : 'text-purple-600' ?>">
                        <i class="ri-calendar-<?= $t['status'] === 'reserved' ? 'close' : 'event' ?>-line"></i>
                        <?= $t['status'] === 'reserved' ? 'Un-reserve' : 'Reserve' ?>
                    </button>
                </form>
                <?php endif; ?>
                <form method="POST" class="contents">
                    <input type="hidden" name="action" value="toggle_table">
                    <?= csrfField() ?>
                    <input type="hidden" name="id" value="<?= $t['id'] ?>">
                    <button type="submit" class="btn btn-ghost btn-sm <?= $t['active'] ? 'text-red-500' : 'text-green-600' ?>">
                        <i class="ri-<?= $t['active'] ? 'close' : 'check' ?>-line"></i> <?= $t['active'] ? 'Disable' : 'Enable' ?>
                    </button>
                </form>
            </div>
        </div>
        <?php endforeach; ?>
    </div>

    <?php else: ?>
    <div class="empty-state card">
        <i class="ri-table-line"></i>
        <p class="font-medium text-gray-700">No tables yet</p>
        <p class="text-sm mt-1">Add your first table to start generating QR codes</p>
        <button onclick="document.getElementById('addTableModal').classList.remove('hidden')" class="btn btn-primary mt-4">Add Table</button>
    </div>
    <?php endif; ?>
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
// ── Render QR codes ──────────────────────────────────────────────────────────
var qrInstances = {};
<?php foreach ($tables as $t):
    $tableUrl = $baseUrl . '/customer/menu.php?token=' . $t['qr_token'];
?>
qrInstances[<?= $t['id'] ?>] = new QRCode(document.getElementById('qr_<?= $t['id'] ?>'), {
    text: '<?= e($tableUrl) ?>',
    width: 80,
    height: 80,
});
<?php endforeach; ?>

// ── Download QR as PNG ───────────────────────────────────────────────────────
function downloadQR(tableId, tableNumber) {
    var el = document.getElementById('qr_' + tableId);
    var canvas = el.querySelector('canvas');
    if (!canvas) return alert('QR not rendered yet.');
    var link = document.createElement('a');
    link.download = 'Table_' + tableNumber + '_QR.png';
    link.href = canvas.toDataURL('image/png');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

// ── Copy to clipboard ──────────────────────────────────────────────────────
function copyText(text, btn) {
    navigator.clipboard.writeText(text).then(function() {
        var orig = btn.innerHTML;
        btn.innerHTML = '<i class="ri-check-line"></i>';
        setTimeout(function() { btn.innerHTML = orig; }, 1500);
    }).catch(function() {
        prompt('Copy this manually:', text);
    });
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

function confirmRegen(n) {
    return confirm('Regenerate QR token for Table ' + n + '?\nExisting QR codes for this table will stop working.');
}

function openEditModal(id, number, capacity) {
    document.getElementById('edit_id').value = id;
    document.getElementById('edit_number').value = number;
    document.getElementById('edit_capacity').value = capacity;
    document.getElementById('editTableModal').classList.remove('hidden');
}
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>