<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$action = $_POST['action'] ?? '';
$msg    = '';
$msgType = 'success';

// Verify CSRF on every POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

// ── Secure image upload helper ────────────────────────────────────────────────
function saveMenuImage(array $file, int $itemId): ?string {
    if (empty($file['name']) || $file['error'] !== UPLOAD_ERR_OK) return null;

    $allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    $allowedExts  = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    // Server-side MIME check (not trusting Content-Type header)
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime  = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mime, $allowedMimes, true)) return null;

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, $allowedExts, true)) return null;

    $uploadDir = __DIR__ . '/../public/uploads/';
    if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);

    // Rename to prevent directory traversal / overwrite attacks
    $filename = 'item_' . $itemId . '_' . time() . '.' . $ext;
    if (!move_uploaded_file($file['tmp_name'], $uploadDir . $filename)) return null;

    return $filename;
}

if ($action === 'add_category' && $_POST['name']) {
    $stmt = db()->prepare("INSERT INTO bar_categories (name, sort_order) VALUES (?, ?)");
    $stmt->execute([$_POST['name'], (int)($_POST['sort_order'] ?? 0)]);
    $msg = 'Category added.';
}

if ($action === 'delete_category' && $_POST['id']) {
    $count = db()->prepare("SELECT COUNT(*) FROM bar_menu_items WHERE category_id = ?");
    $count->execute([(int)$_POST['id']]);
    if ($count->fetchColumn() > 0) {
        $msg = 'Cannot delete: category has items.';
    } else {
        db()->prepare("DELETE FROM bar_categories WHERE id = ?")->execute([(int)$_POST['id']]);
        $msg = 'Category deleted.';
    }
}

if ($action === 'add_item') {
    $stmt = db()->prepare("INSERT INTO bar_menu_items (category_id, name, description, price) VALUES (?, ?, ?, ?)");
    $stmt->execute([(int)$_POST['category_id'], $_POST['name'], $_POST['description'] ?? '', str_replace(',', '', $_POST['price'])]);
    $itemId = db()->lastInsertId();

    if (!empty($_FILES['image']['name'])) {
        $filename = saveMenuImage($_FILES['image'], $itemId);
        if ($filename) {
            db()->prepare("UPDATE bar_menu_items SET image = ? WHERE id = ?")->execute([$filename, $itemId]);
        } else {
            $msg = 'Item added, but image was rejected (invalid type). Only JPG, PNG, GIF, WEBP allowed.';
            $msgType = 'warn';
        }
    }
    if (!$msg) $msg = 'Menu item added.';
    auditLog('menu_add_item', "item #{$itemId}", $_POST['name']);
}

if ($action === 'edit_item' && $_POST['id']) {
    $id = (int)$_POST['id'];
    $stmt = db()->prepare("UPDATE bar_menu_items SET category_id = ?, name = ?, description = ?, price = ? WHERE id = ?");
    $stmt->execute([(int)$_POST['category_id'], $_POST['name'], $_POST['description'] ?? '', str_replace(',', '', $_POST['price']), $id]);

    if (!empty($_FILES['image']['name'])) {
        $filename = saveMenuImage($_FILES['image'], $id);
        if ($filename) {
            db()->prepare("UPDATE bar_menu_items SET image = ? WHERE id = ?")->execute([$filename, $id]);
        } else {
            $msg = 'Item updated, but new image was rejected (invalid type).';
            $msgType = 'warn';
        }
    }
    if (!$msg) $msg = 'Menu item updated.';
    auditLog('menu_edit_item', "item #{$id}", $_POST['name']);
}

if ($action === 'delete_item' && $_POST['id']) {
    db()->prepare("DELETE FROM bar_menu_items WHERE id = ?")->execute([(int)$_POST['id']]);
    $msg = 'Menu item deleted.';
}

if ($action === 'toggle_item' && $_POST['id']) {
    $stmt = db()->prepare("UPDATE bar_menu_items SET active = NOT active WHERE id = ?");
    $stmt->execute([(int)$_POST['id']]);
    header('Location: /bar/pages/menu.php');
    exit;
}

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$categories = db()->query("SELECT c.*, (SELECT COUNT(*) FROM bar_menu_items WHERE category_id = c.id) AS item_count FROM bar_categories c ORDER BY sort_order")->fetchAll();
$items = db()->query("SELECT mi.*, c.name AS category_name FROM bar_menu_items mi JOIN bar_categories c ON c.id = mi.category_id ORDER BY c.sort_order, mi.name")->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-restaurant-line text-amber-500 mr-1"></i> Menu Management</h2>
        <div class="flex flex-wrap gap-2">
            <button onclick="document.getElementById('addCatModal').classList.remove('hidden')" class="btn btn-outline btn-sm"><i class="ri-add-line"></i> Category</button>
            <button onclick="document.getElementById('addItemModal').classList.remove('hidden')" class="btn btn-primary btn-sm"><i class="ri-add-line"></i> Item</button>
        </div>
    </div>

    <?php if ($msg): ?>
    <div class="<?= $msgType === 'warn' ? 'bg-amber-50 text-amber-700 border-amber-200' : 'bg-green-50 text-green-700 border-green-200' ?> border px-4 py-3 rounded-lg mb-4 flex items-center gap-2">
        <i class="<?= $msgType === 'warn' ? 'ri-alert-line' : 'ri-checkbox-circle-fill' ?>"></i> <?= e($msg) ?>
    </div>
    <?php endif; ?>

    <?php if ($categories): ?>
    <div class="flex flex-wrap gap-2 mb-4">
        <button class="cat-filter active" data-cat-id="" onclick="filterCategory(this)">All</button>
        <?php foreach ($categories as $cat): ?>
        <button class="cat-filter" data-cat-id="<?= $cat['id'] ?>" onclick="filterCategory(this)">
            <?= e($cat['name']) ?>
            <span class="text-xs opacity-60"><?= $cat['item_count'] ?></span>
            <form method="POST" class="inline" onsubmit="return confirmDelete('Delete category &quot;<?= e($cat['name']) ?>&quot;?')">
                <input type="hidden" name="action" value="delete_category">
                <?= csrfField() ?>
                <input type="hidden" name="id" value="<?= $cat['id'] ?>">
                <button type="submit" class="text-inherit opacity-40 hover:opacity-100 ml-0.5"><i class="ri-close-line text-sm"></i></button>
            </form>
        </button>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>

    <div class="card">
        <?php if ($items): ?>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Category</th><th>Name</th><th>Price</th><th>Status</th><th class="text-right">Actions</th></tr>
                </thead>
                <tbody id="menuTableBody">
                    <?php foreach ($items as $item): ?>
                    <tr data-cat-id="<?= $item['category_id'] ?>">
                        <td><span class="text-xs text-gray-500 cat-label" onclick="filterByCat(<?= $item['category_id'] ?>, '<?= e(str_replace("'", "\\'", $item['category_name'])) ?>')" style="cursor:pointer;"><?= e($item['category_name']) ?></span></td>
                        <td class="font-medium">
                            <?php if ($item['image']): ?>
                            <div class="flex items-center gap-2">
                                <img src="/bar/public/uploads/<?= e($item['image']) ?>" alt="" class="w-14 h-14 rounded-lg object-cover shadow-sm border">
                                <div>
                                    <?= e($item['name']) ?>
                                    <?php if ($item['description']): ?>
                                    <span class="text-xs text-gray-400 block"><?= e($item['description']) ?></span>
                                    <?php endif; ?>
                                </div>
                            </div>
                            <?php else: ?>
                            <div class="flex items-center gap-2">
                                <span class="w-14 h-14 rounded-lg bg-gray-100 text-gray-300 flex items-center justify-center border"><i class="ri-image-line text-xl"></i></span>
                                <?= e($item['name']) ?>
                                <?php if ($item['description']): ?>
                                <span class="text-xs text-gray-400 block"><?= e($item['description']) ?></span>
                                <?php endif; ?>
                            </div>
                            <?php endif; ?>
                        </td>
                        <td class="font-semibold"><?= money($item['price']) ?></td>
                        <td><span class="badge <?= $item['active'] ? 'badge-ready' : 'badge-closed' ?>"><?= $item['active'] ? 'Active' : 'Inactive' ?></span></td>
                        <td class="text-right">
                            <div class="flex gap-1 justify-end">
                                <button onclick="editItem(<?= $item['id'] ?>, <?= $item['category_id'] ?>, '<?= e(str_replace("'", "\\'", $item['name'])) ?>', '<?= e(str_replace("'", "\\'", $item['description'])) ?>', <?= $item['price'] ?>)" class="btn btn-ghost btn-sm"><i class="ri-pencil-line"></i></button>
                                <form method="POST" class="inline">
                                    <input type="hidden" name="action" value="toggle_item">
                    <?= csrfField() ?>
                                    <input type="hidden" name="id" value="<?= $item['id'] ?>">
                                    <button type="submit" class="btn btn-ghost btn-sm <?= $item['active'] ? 'text-amber-600' : 'text-green-600' ?>">
                                        <?= $item['active'] ? '<i class="ri-pause-line"></i>' : '<i class="ri-play-line"></i>' ?>
                                    </button>
                                </form>
                                <form method="POST" class="inline" onsubmit="return confirmDelete('Delete &quot;<?= e($item['name']) ?>&quot;?')">
                                    <input type="hidden" name="action" value="delete_item">
                    <?= csrfField() ?>
                                    <input type="hidden" name="id" value="<?= $item['id'] ?>">
                                    <button type="submit" class="btn btn-ghost btn-sm text-red-500"><i class="ri-delete-bin-line"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
        <div class="empty-state">
            <i class="ri-restaurant-line"></i>
            <p class="font-medium text-gray-700">No menu items yet</p>
            <p class="text-sm mt-1">Add categories and items to start taking orders</p>
            <button onclick="document.getElementById('addCatModal').classList.remove('hidden')" class="btn btn-primary mt-4 btn-sm">Add Category</button>
            <button onclick="document.getElementById('addItemModal').classList.remove('hidden')" class="btn btn-outline mt-2 btn-sm">Add Item</button>
        </div>
        <?php endif; ?>
    </div>

    <!-- Add Category Modal -->
    <div id="addCatModal" class="modal-overlay hidden">
        <div class="modal-content">
            <div class="modal-header"><h3 class="modal-title"><i class="ri-folder-add-line mr-1"></i> Add Category</h3><button type="button" onclick="document.getElementById('addCatModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button></div>
            <form method="POST">
                <input type="hidden" name="action" value="add_category">
                <?= csrfField() ?>
                <div class="space-y-3">
                    <input type="text" name="name" placeholder="Category name" class="form-input" required>
                    <input type="number" name="sort_order" placeholder="Sort order (0, 1, 2...)" class="form-input" value="0">
                </div>
                <div class="flex gap-2 mt-4">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" onclick="document.getElementById('addCatModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Item Modal -->
    <div id="addItemModal" class="modal-overlay hidden">
        <div class="modal-content max-w-md">
            <div class="modal-header"><h3 class="modal-title"><i class="ri-add-circle-line mr-1"></i> Add Menu Item</h3><button type="button" onclick="document.getElementById('addItemModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button></div>
            <form method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="add_item">
                <?= csrfField() ?>
                <div class="space-y-3">
                    <select name="category_id" class="form-select" required>
                        <option value="">Select category</option>
                        <?php foreach ($categories as $cat): ?>
                        <option value="<?= $cat['id'] ?>"><?= e($cat['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <input type="text" name="name" placeholder="Item name" class="form-input" required>
                    <textarea name="description" placeholder="Description" class="form-textarea" rows="2"></textarea>
                    <input type="text" name="price" placeholder="Price (e.g., 5.50)" class="form-input" required>
                    <div>
                        <label class="form-label">Image (optional)</label>
                        <input type="file" name="image" class="form-input" accept="image/*">
                    </div>
                </div>
                <div class="flex gap-2 mt-4">
                    <button type="submit" class="btn btn-primary">Save</button>
                    <button type="button" onclick="document.getElementById('addItemModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Item Modal -->
    <div id="editItemModal" class="modal-overlay hidden">
        <div class="modal-content max-w-md">
            <div class="modal-header"><h3 class="modal-title"><i class="ri-edit-line mr-1"></i> Edit Menu Item</h3><button type="button" onclick="document.getElementById('editItemModal').classList.add('hidden')" class="modal-close"><i class="ri-close-line"></i></button></div>
            <form method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="edit_item">
                <?= csrfField() ?>
                <input type="hidden" name="id" id="editId">
                <div class="space-y-3">
                    <select name="category_id" id="editCategory" class="form-select" required>
                        <option value="">Select category</option>
                        <?php foreach ($categories as $cat): ?>
                        <option value="<?= $cat['id'] ?>"><?= e($cat['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                    <input type="text" name="name" id="editName" placeholder="Item name" class="form-input" required>
                    <textarea name="description" id="editDescription" placeholder="Description" class="form-textarea" rows="2"></textarea>
                    <input type="text" name="price" id="editPrice" placeholder="Price (e.g., 5.50)" class="form-input" required>
                    <div>
                        <label class="form-label">New image (optional)</label>
                        <input type="file" name="image" class="form-input" accept="image/*">
                    </div>
                </div>
                <div class="flex gap-2 mt-4">
                    <button type="submit" class="btn btn-primary">Update</button>
                    <button type="button" onclick="document.getElementById('editItemModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function editItem(id, catId, name, description, price) {
    document.getElementById('editId').value = id;
    document.getElementById('editCategory').value = catId;
    document.getElementById('editName').value = name;
    document.getElementById('editDescription').value = description;
    document.getElementById('editPrice').value = price;
    document.getElementById('editItemModal').classList.remove('hidden');
}

function filterCategory(btn) {
    var catId = btn.dataset.catId;
    document.querySelectorAll('.cat-filter').forEach(function(b) {
        b.classList.remove('active');
    });
    btn.classList.add('active');
    document.querySelectorAll('#menuTableBody tr').forEach(function(row) {
        row.style.display = !catId || row.dataset.catId === catId ? '' : 'none';
    });
}

function filterByCat(catId, catName) {
    var btn = document.querySelector('.cat-filter[data-cat-id="' + catId + '"]');
    if (btn) filterCategory(btn);
}
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>