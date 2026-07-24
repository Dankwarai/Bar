<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$action = $_POST['action'] ?? '';
$msg = ''; $msgType = 'success';

if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

// ── Add mapping ───────────────────────────────────────────────────────────────
if ($action === 'add_mapping') {
    $menuItemId  = (int)$_POST['menu_item_id'];
    $inventoryId = (int)$_POST['inventory_id'];
    $qtyPerSale  = max(0.0001, (float)str_replace(',', '', $_POST['qty_per_sale'] ?? '1'));
    try {
        db()->prepare("INSERT INTO bar_menu_inventory (menu_item_id, inventory_id, qty_per_sale) VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE qty_per_sale = VALUES(qty_per_sale)")
            ->execute([$menuItemId, $inventoryId, $qtyPerSale]);
        auditLog('mapping_add', "menu_item #{$menuItemId} → inv #{$inventoryId}", "qty:{$qtyPerSale}");
        $msg = 'Mapping saved.';
    } catch (Exception $e) {
        $msg = 'Error: ' . $e->getMessage(); $msgType = 'error';
    }
}

// ── Delete mapping ────────────────────────────────────────────────────────────
if ($action === 'delete_mapping') {
    $id = (int)$_POST['id'];
    db()->prepare("DELETE FROM bar_menu_inventory WHERE id = ?")->execute([$id]);
    $msg = 'Mapping removed.';
}

// ── Page data ─────────────────────────────────────────────────────────────────
$menuItems = db()->query("
    SELECT mi.id, mi.name, c.name AS category_name
    FROM bar_menu_items mi
    JOIN bar_categories c ON c.id = mi.category_id
    WHERE mi.active = 1
    ORDER BY c.sort_order, mi.name
")->fetchAll();

$inventoryItems = db()->query("SELECT id, name, unit FROM bar_inventory ORDER BY name")->fetchAll();

// All existing mappings with names
$mappings = db()->query("
    SELECT bmi.id, bmi.qty_per_sale,
           mi.name AS menu_item_name,
           inv.name AS inventory_name, inv.unit
    FROM bar_menu_inventory bmi
    JOIN bar_menu_items mi ON mi.id = bmi.menu_item_id
    JOIN bar_inventory inv ON inv.id = bmi.inventory_id
    ORDER BY mi.name, inv.name
")->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <div>
            <h2 class="page-title"><i class="ri-links-line text-amber-500 mr-1"></i> Menu → Inventory Mapping</h2>
            <p class="text-xs text-gray-400 mt-0.5">Define how much stock each sale depletes automatically.</p>
        </div>
        <button onclick="document.getElementById('addMappingModal').classList.remove('hidden')" class="btn btn-primary btn-sm">
            <i class="ri-add-line"></i> Add Mapping
        </button>
    </div>

    <?php if ($msg): ?>
    <div class="<?= $msgType === 'error' ? 'bg-red-50 text-red-700 border-red-200' : 'bg-green-50 text-green-700 border-green-200' ?> border px-4 py-3 rounded-lg mb-4 text-sm flex items-center gap-2">
        <i class="<?= $msgType === 'error' ? 'ri-close-circle-fill' : 'ri-checkbox-circle-fill' ?>"></i> <?= e($msg) ?>
    </div>
    <?php endif; ?>

    <?php if (empty($inventoryItems)): ?>
    <div class="card mb-4 bg-amber-50 border border-amber-200 text-amber-700 text-sm p-4">
        <i class="ri-alert-line mr-1"></i>
        No inventory items exist yet. <a href="/bar/pages/inventory.php" class="underline font-medium">Add stock items first</a>, then come back to create mappings.
    </div>
    <?php endif; ?>

    <?php if (empty($mappings)): ?>
    <div class="empty-state card">
        <i class="ri-links-line"></i>
        <p class="font-medium text-gray-700">No mappings yet</p>
        <p class="text-sm mt-1 text-gray-400">Add a mapping so that selling a menu item automatically deducts stock.</p>
        <button onclick="document.getElementById('addMappingModal').classList.remove('hidden')" class="btn btn-primary mt-4 btn-sm">
            <i class="ri-add-line"></i> Add First Mapping
        </button>
    </div>
    <?php else: ?>
    <div class="card p-0">
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Menu Item</th>
                        <th>Depletes Stock Item</th>
                        <th>Qty per Sale</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($mappings as $m): ?>
                    <tr>
                        <td class="font-medium"><?= e($m['menu_item_name']) ?></td>
                        <td><?= e($m['inventory_name']) ?></td>
                        <td>
                            <span class="font-mono text-sm"><?= e($m['qty_per_sale']) ?></span>
                            <span class="text-xs text-gray-400 ml-1"><?= e($m['unit']) ?></span>
                        </td>
                        <td class="text-right">
                            <form method="POST" class="inline"
                                  onsubmit="return confirm('Remove this mapping?')">
                                <?= csrfField() ?>
                                <input type="hidden" name="action" value="delete_mapping">
                                <input type="hidden" name="id" value="<?= $m['id'] ?>">
                                <button type="submit" class="btn btn-ghost btn-sm text-red-500">
                                    <i class="ri-delete-bin-line"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-xl text-sm text-blue-700">
        <i class="ri-information-line mr-1"></i>
        <strong>How it works:</strong> When a menu item is checked out, its linked inventory is automatically reduced.
        Set <em>qty_per_sale = 1</em> for bottles, <em>0.33</em> if 1 sale uses 330ml from a 1L stock item, etc.
        One menu item can have multiple inventory links (e.g. a cocktail depletes rum + lime + soda).
    </div>
    <?php endif; ?>
</div>

<!-- Add Mapping Modal -->
<div id="addMappingModal" class="modal-overlay hidden">
    <div class="modal-content max-w-md">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-links-line mr-1"></i> Add Mapping</h3>
            <button type="button" onclick="document.getElementById('addMappingModal').classList.add('hidden')" class="modal-close">
                <i class="ri-close-line"></i>
            </button>
        </div>
        <form method="POST">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="add_mapping">
            <div class="space-y-4">
                <div>
                    <label class="form-label">Menu Item <span class="text-red-500">*</span></label>
                    <select name="menu_item_id" class="form-select" required>
                        <option value="">Select menu item…</option>
                        <?php
                        $lastCat = '';
                        foreach ($menuItems as $mi):
                            if ($mi['category_name'] !== $lastCat) {
                                if ($lastCat) echo '</optgroup>';
                                echo '<optgroup label="' . e($mi['category_name']) . '">';
                                $lastCat = $mi['category_name'];
                            }
                        ?>
                        <option value="<?= $mi['id'] ?>"><?= e($mi['name']) ?></option>
                        <?php endforeach; ?>
                        <?php if ($lastCat) echo '</optgroup>'; ?>
                    </select>
                </div>
                <div>
                    <label class="form-label">Stock Item to Deplete <span class="text-red-500">*</span></label>
                    <select name="inventory_id" class="form-select" required>
                        <option value="">Select inventory item…</option>
                        <?php foreach ($inventoryItems as $inv): ?>
                        <option value="<?= $inv['id'] ?>"><?= e($inv['name']) ?> (<?= e($inv['unit']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="form-label">Quantity Depleted per Sale <span class="text-red-500">*</span></label>
                    <input type="number" name="qty_per_sale" step="0.0001" min="0.0001"
                           value="1" class="form-input" required>
                    <p class="text-xs text-gray-400 mt-1">
                        e.g. <strong>1</strong> for 1 bottle, <strong>0.33</strong> for 330ml from a litre, <strong>2</strong> for a double.
                    </p>
                </div>
            </div>
            <div class="flex gap-2 mt-5">
                <button type="submit" class="btn btn-primary flex-1">Save Mapping</button>
                <button type="button" onclick="document.getElementById('addMappingModal').classList.add('hidden')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
