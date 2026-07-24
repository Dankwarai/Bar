<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$action = $_POST['action'] ?? '';
$msg = ''; $msgType = 'success';

if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

if ($action === 'add') {
    db()->prepare("INSERT INTO bar_suppliers (name, contact_person, phone, email, address, notes) VALUES (?, ?, ?, ?, ?, ?)")
        ->execute([trim($_POST['name']), trim($_POST['contact_person'] ?? ''), trim($_POST['phone'] ?? ''), trim($_POST['email'] ?? ''), trim($_POST['address'] ?? ''), trim($_POST['notes'] ?? '')]);
    auditLog('supplier_add', $_POST['name'], '');
    $msg = 'Supplier added.';
}

if ($action === 'edit') {
    $id = (int)$_POST['id'];
    db()->prepare("UPDATE bar_suppliers SET name=?, contact_person=?, phone=?, email=?, address=?, notes=? WHERE id=?")
        ->execute([trim($_POST['name']), trim($_POST['contact_person'] ?? ''), trim($_POST['phone'] ?? ''), trim($_POST['email'] ?? ''), trim($_POST['address'] ?? ''), trim($_POST['notes'] ?? ''), $id]);
    auditLog('supplier_edit', "supplier #{$id}", $_POST['name']);
    $msg = 'Supplier updated.';
}

if ($action === 'toggle') {
    $id = (int)$_POST['id'];
    $stmt = db()->prepare("UPDATE bar_suppliers SET active = NOT active WHERE id = ?");
    $stmt->execute([$id]);
    header('Location: /bar/pages/suppliers.php');
    exit;
}

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$suppliers = db()->query("SELECT s.*, (SELECT COUNT(*) FROM bar_inventory WHERE supplier_id = s.id) AS item_count FROM bar_suppliers s ORDER BY s.name")->fetchAll();
$inventoryCount = db()->query("SELECT COUNT(*) FROM bar_inventory")->fetchColumn();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-truck-line text-amber-500 mr-1"></i> Suppliers</h2>
        <button onclick="document.getElementById('addModal').classList.remove('hidden')" class="btn btn-primary btn-sm"><i class="ri-add-line"></i> Add Supplier</button>
    </div>

    <?php if ($msg): ?>
    <div class="<?= $msgType === 'error' ? 'bg-red-50 text-red-700 border-red-200' : 'bg-green-50 text-green-700 border-green-200' ?> border px-4 py-3 rounded-lg mb-4 flex items-center gap-2 text-sm">
        <i class="<?= $msgType === 'error' ? 'ri-close-circle-fill' : 'ri-checkbox-circle-fill' ?>"></i> <?= e($msg) ?>
    </div>
    <?php endif; ?>

    <?php if ($suppliers): ?>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <?php foreach ($suppliers as $s): ?>
        <div class="card <?= $s['active'] ? '' : 'opacity-50' ?>">
            <div class="flex items-start justify-between mb-3">
                <div class="flex items-center gap-2.5">
                    <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-100 to-amber-200 flex items-center justify-center text-amber-600">
                        <i class="ri-truck-line text-lg"></i>
                    </div>
                    <div>
                        <h4 class="font-semibold"><?= e($s['name'] ?: 'Unnamed') ?></h4>
                        <?php if ($s['contact_person']): ?>
                        <p class="text-xs text-gray-400"><?= e($s['contact_person']) ?></p>
                        <?php endif; ?>
                    </div>
                </div>
                <form method="POST" class="inline">
                    <input type="hidden" name="action" value="toggle">
                    <?= csrfField() ?>
                    <input type="hidden" name="id" value="<?= $s['id'] ?>">
                    <button type="submit" class="text-sm <?= $s['active'] ? 'text-green-500' : 'text-gray-400 hover:text-green-500' ?>">
                        <i class="ri-checkbox-circle<?= $s['active'] ? '-fill' : '-line' ?>"></i>
                    </button>
                </form>
            </div>
            <div class="space-y-1 text-sm text-gray-600 mb-3">
                <?php if ($s['phone']): ?>
                <p><i class="ri-phone-line text-gray-300 mr-1.5"></i> <?= e($s['phone']) ?></p>
                <?php endif; ?>
                <?php if ($s['email']): ?>
                <p><i class="ri-mail-line text-gray-300 mr-1.5"></i> <?= e($s['email']) ?></p>
                <?php endif; ?>
                <?php if ($s['address']): ?>
                <p><i class="ri-map-pin-line text-gray-300 mr-1.5"></i> <?= e($s['address']) ?></p>
                <?php endif; ?>
            </div>
            <div class="flex items-center justify-between pt-2 border-t border-gray-100">
                <span class="text-xs text-gray-400">
                    <?= $s['item_count'] ?> linked item<?= $s['item_count'] !== 1 ? 's' : '' ?>
                    <?php if ($s['notes']): ?>
                    &middot; <span title="<?= e($s['notes']) ?>"><i class="ri-information-line"></i></span>
                    <?php endif; ?>
                </span>
                <div class="flex gap-1">
                    <button onclick="editSupplier(<?= htmlspecialchars(json_encode($s), ENT_QUOTES) ?>)" class="btn btn-ghost btn-sm text-blue-600">
                        <i class="ri-edit-line"></i>
                    </button>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
    <?php else: ?>
    <div class="empty-state card">
        <i class="ri-truck-line"></i>
        <p class="font-medium text-gray-700">No suppliers yet</p>
        <p class="text-sm mt-1">Add suppliers to track who you order from</p>
        <button onclick="document.getElementById('addModal').classList.remove('hidden')" class="btn btn-primary mt-4 btn-sm">Add First Supplier</button>
    </div>
    <?php endif; ?>
</div>

<!-- Add Modal -->
<div id="addModal" class="modal-overlay hidden">
    <div class="modal-content max-w-lg">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-add-circle-line mr-1"></i> Add Supplier</h3>
            <button type="button" onclick="document.getElementById('addModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="add">
            <?= csrfField() ?>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div class="md:col-span-2"><label class="form-label">Company Name <span class="text-red-500">*</span></label><input type="text" name="name" class="form-input" required></div>
                <div><label class="form-label">Contact Person</label><input type="text" name="contact_person" class="form-input"></div>
                <div><label class="form-label">Phone</label><input type="text" name="phone" class="form-input"></div>
                <div><label class="form-label">Email</label><input type="email" name="email" class="form-input"></div>
                <div class="md:col-span-2"><label class="form-label">Address</label><textarea name="address" class="form-textarea" rows="2"></textarea></div>
                <div class="md:col-span-2"><label class="form-label">Notes</label><textarea name="notes" class="form-textarea" rows="2"></textarea></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">Save</button>
                <button type="button" onclick="document.getElementById('addModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Modal -->
<div id="editModal" class="modal-overlay hidden">
    <div class="modal-content max-w-lg">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-edit-line mr-1"></i> Edit Supplier</h3>
            <button type="button" onclick="document.getElementById('editModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="edit">
            <?= csrfField() ?>
            <input type="hidden" name="id" id="editId">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div class="md:col-span-2"><label class="form-label">Company Name <span class="text-red-500">*</span></label><input type="text" name="name" id="editName" class="form-input" required></div>
                <div><label class="form-label">Contact Person</label><input type="text" name="contact_person" id="editContact" class="form-input"></div>
                <div><label class="form-label">Phone</label><input type="text" name="phone" id="editPhone" class="form-input"></div>
                <div><label class="form-label">Email</label><input type="email" name="email" id="editEmail" class="form-input"></div>
                <div class="md:col-span-2"><label class="form-label">Address</label><textarea name="address" id="editAddress" class="form-textarea" rows="2"></textarea></div>
                <div class="md:col-span-2"><label class="form-label">Notes</label><textarea name="notes" id="editNotes" class="form-textarea" rows="2"></textarea></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">Update</button>
                <button type="button" onclick="document.getElementById('editModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
function editSupplier(data) {
    document.getElementById('editId').value = data.id;
    document.getElementById('editName').value = data.name || '';
    document.getElementById('editContact').value = data.contact_person || '';
    document.getElementById('editPhone').value = data.phone || '';
    document.getElementById('editEmail').value = data.email || '';
    document.getElementById('editAddress').value = data.address || '';
    document.getElementById('editNotes').value = data.notes || '';
    document.getElementById('editModal').classList.remove('hidden');
}
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>