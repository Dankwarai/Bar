<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager', 'bartender');

$action = $_POST['action'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

// ── Add new inventory item ────────────────────────────────────────────────────
if ($action === 'add_item') {
    $stmt = db()->prepare("INSERT INTO bar_inventory (name, quantity, unit, supplier_id, cost_price, low_stock_threshold) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        trim($_POST['name']),
        str_replace(',', '', $_POST['quantity']),
        trim($_POST['unit']),
        $_POST['supplier_id'] ? (int)$_POST['supplier_id'] : null,
        $_POST['cost_price'] ? (float)str_replace(',', '', $_POST['cost_price']) : null,
        (float)($_POST['threshold'] ?? 10),
    ]);
    $id = db()->lastInsertId();
    db()->prepare("INSERT INTO bar_inventory_transactions (inventory_id, type, quantity, note) VALUES (?, 'in', ?, 'Initial stock')")
        ->execute([$id, str_replace(',', '', $_POST['quantity'])]);
    auditLog('stock_add_item', "item #{$id}", $_POST['name']);
    header('Location: /bar/pages/inventory.php');
    exit;
}

// ── Edit item ─────────────────────────────────────────────────────────────────
if ($action === 'edit_item') {
    requireRole('admin', 'manager');
    $id = (int)$_POST['id'];
    db()->prepare("UPDATE bar_inventory SET name=?, unit=?, supplier_id=?, cost_price=?, low_stock_threshold=? WHERE id=?")
        ->execute([
            trim($_POST['name']),
            trim($_POST['unit']),
            $_POST['supplier_id'] ? (int)$_POST['supplier_id'] : null,
            $_POST['cost_price'] ? (float)str_replace(',', '', $_POST['cost_price']) : null,
            (float)$_POST['threshold'],
            $id,
        ]);
    header('Location: /bar/pages/inventory.php?msg=updated');
    exit;
}

// ── Delete item ───────────────────────────────────────────────────────────────
if ($action === 'delete_item') {
    requireRole('admin', 'manager');
    $id = (int)$_POST['id'];
    db()->prepare("DELETE FROM bar_inventory WHERE id = ?")->execute([$id]);
    header('Location: /bar/pages/inventory.php?msg=deleted');
    exit;
}

// ── Create menu item from inventory ──────────────────────────────────────────
if ($action === 'create_menu_item') {
    requireRole('admin', 'manager');
    $invId = (int)$_POST['inventory_id'];
    $catId = (int)$_POST['category_id'];
    $price = (float)str_replace(',', '', $_POST['price']);
    $name  = trim($_POST['name']);

    if ($name && $catId && $price > 0) {
        $stmt = db()->prepare("INSERT INTO bar_menu_items (category_id, name, description, price) VALUES (?, ?, ?, ?)");
        $stmt->execute([$catId, $name, 'Auto-created from inventory', $price]);
        $menuId = db()->lastInsertId();

        // Auto-create inventory mapping (1:1)
        $check = db()->prepare("SELECT COUNT(*) FROM bar_menu_inventory WHERE menu_item_id = ? AND inventory_id = ?");
        $check->execute([$menuId, $invId]);
        if ($check->fetchColumn() == 0) {
            db()->prepare("INSERT INTO bar_menu_inventory (menu_item_id, inventory_id, qty_per_sale) VALUES (?, ?, 1)")
                ->execute([$menuId, $invId]);
        }
        auditLog('stock_create_menu', "inv #{$invId} → menu #{$menuId}", $name);
        $msg = 'created';
    }
    header('Location: /bar/pages/inventory.php?msg=' . ($name && $catId && $price > 0 ? 'menu_created' : 'menu_failed'));
    exit;
}

// ── Restock ───────────────────────────────────────────────────────────────────
if ($action === 'restock') {
    $id   = (int)$_POST['id'];
    $qty  = (float)str_replace(',', '', $_POST['quantity']);
    if ($qty <= 0) { header('Location: /bar/pages/inventory.php'); exit; }
    $supplierId = $_POST['supplier_id'] ? (int)$_POST['supplier_id'] : null;
    $unitCost   = $_POST['unit_cost'] ? (float)str_replace(',', '', $_POST['unit_cost']) : null;
    $totalCost  = $unitCost ? round($unitCost * $qty, 2) : null;
    $note       = trim($_POST['note'] ?? '');

    db()->beginTransaction();
    db()->prepare("UPDATE bar_inventory SET quantity = quantity + ? WHERE id = ?")->execute([$qty, $id]);
    db()->prepare("INSERT INTO bar_inventory_transactions (inventory_id, type, quantity, note) VALUES (?, 'in', ?, ?)")
        ->execute([$id, $qty, $note ?: 'Restock']);
    db()->prepare("INSERT INTO bar_restocks (inventory_id, supplier_id, quantity, unit_cost, total_cost, note, received_by) VALUES (?, ?, ?, ?, ?, ?, ?)")
        ->execute([$id, $supplierId, $qty, $unitCost, $totalCost, $note, $_SESSION['user_id'] ?? null]);
    // Update cost_price to latest
    if ($unitCost) {
        db()->prepare("UPDATE bar_inventory SET cost_price = ? WHERE id = ?")->execute([$unitCost, $id]);
    }
    db()->commit();

    $nameStmt = db()->prepare("SELECT name FROM bar_inventory WHERE id = ?");
    $nameStmt->execute([$id]);
    $itemName = $nameStmt->fetchColumn() ?: "id:{$id}";
    auditLog('stock_restock', $itemName, "+{$qty}" . ($note ? " — {$note}" : ''));
    header('Location: /bar/pages/inventory.php');
    exit;
}

// ── Adjust stock ──────────────────────────────────────────────────────────────
if ($action === 'adjust_stock') {
    $id   = (int)$_POST['id'];
    $qty  = (float)str_replace(',', '', $_POST['quantity']);
    $type = $_POST['adj_type'];
    $note = trim($_POST['note'] ?? '');
    db()->prepare("INSERT INTO bar_inventory_transactions (inventory_id, type, quantity, note) VALUES (?, ?, ?, ?)")
        ->execute([$id, $type, $qty, $note]);
    if ($type === 'in') {
        db()->prepare("UPDATE bar_inventory SET quantity = quantity + ? WHERE id = ?")->execute([$qty, $id]);
    } elseif ($type === 'out') {
        db()->prepare("UPDATE bar_inventory SET quantity = GREATEST(0, quantity - ?) WHERE id = ?")->execute([$qty, $id]);
    } else {
        db()->prepare("UPDATE bar_inventory SET quantity = ? WHERE id = ?")->execute([$qty, $id]);
    }
    $nameStmt = db()->prepare("SELECT name FROM bar_inventory WHERE id = ?");
    $nameStmt->execute([$id]);
    $itemName = $nameStmt->fetchColumn() ?: "id:{$id}";
    auditLog('stock_adjust', $itemName, "{$type} {$qty}" . ($note ? " — {$note}" : ''));
    // Sync menu item active state based on new stock level
    syncMenuItemAvailability($id);
    header('Location: /bar/pages/inventory.php');
    exit;
}

// ── Load data ─────────────────────────────────────────────────────────────────
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$items = db()->query("SELECT i.*, s.name AS supplier_name FROM bar_inventory i LEFT JOIN bar_suppliers s ON s.id = i.supplier_id ORDER BY i.name")->fetchAll();
$suppliers = db()->query("SELECT id, name FROM bar_suppliers WHERE active = 1 ORDER BY name")->fetchAll();
$categories = db()->query("SELECT id, name FROM bar_categories ORDER BY sort_order")->fetchAll();
// Items that already have a menu link
$linkedInvIds = [];
foreach ($items as $item) {
    $c = db()->prepare("SELECT COUNT(*) FROM bar_menu_inventory WHERE inventory_id = ?");
    $c->execute([$item['id']]);
    if ($c->fetchColumn() > 0) $linkedInvIds[] = $item['id'];
}
$lowStock   = 0;
$outOfStock = 0;
$totalItems = count($items);
$totalValue = 0;
foreach ($items as $item) {
    if ($item['quantity'] <= 0) $outOfStock++;
    elseif ($item['quantity'] <= $item['low_stock_threshold']) $lowStock++;
    if ($item['cost_price']) $totalValue += $item['quantity'] * $item['cost_price'];
}
$msg = $_GET['msg'] ?? '';

// Recent 50 transactions with item name
$transactions = db()->query("
    SELECT t.*, i.name AS item_name
    FROM bar_inventory_transactions t
    JOIN bar_inventory i ON i.id = t.inventory_id
    ORDER BY t.created_at DESC
    LIMIT 50
")->fetchAll();

// Recent restocks
$restocks = db()->query("
    SELECT r.*, i.name AS item_name, s.name AS supplier_name, u.name AS user_name
    FROM bar_restocks r
    JOIN bar_inventory i ON i.id = r.inventory_id
    LEFT JOIN bar_suppliers s ON s.id = r.supplier_id
    LEFT JOIN bar_users u ON u.id = r.received_by
    ORDER BY r.created_at DESC
    LIMIT 20
")->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-stock-line text-amber-500 mr-1"></i> Inventory</h2>
        <div class="flex flex-wrap gap-2">
            <button onclick="document.getElementById('restockModal').classList.remove('hidden')" class="btn btn-accent btn-sm">
                <i class="ri-refresh-line"></i> Restock
            </button>
            <button onclick="document.getElementById('addItemModal').classList.remove('hidden')" class="btn btn-primary btn-sm">
                <i class="ri-add-line"></i> Add Item
            </button>
        </div>
    </div>

    <?php if ($msg === 'updated'): ?>
    <div class="flex items-center gap-2 bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-information-fill text-blue-500"></i> Item updated.
    </div>
    <?php elseif ($msg === 'deleted'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-delete-bin-fill text-red-500"></i> Item deleted.
    </div>
    <?php elseif ($msg === 'menu_created'): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-checkbox-circle-fill text-green-500"></i> Menu item created and linked to inventory.
    </div>
    <?php elseif ($msg === 'menu_failed'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> Failed to create menu item. Check name, category, and price.
    </div>
    <?php endif; ?>

    <?php if ($items): ?>
    <!-- Stats -->
    <div class="stats-grid mb-6">
        <div class="stat-card">
            <div class="stat-value"><?= $totalItems ?></div>
            <div class="stat-label">Stock Items</div>
            <i class="ri-stock-line stat-icon"></i>
        </div>
        <div class="stat-card <?= $lowStock > 0 ? 'border-amber-500' : '' ?>">
            <div class="stat-value <?= $lowStock > 0 ? 'text-amber-600' : '' ?>"><?= $lowStock ?></div>
            <div class="stat-label">Low Stock</div>
            <i class="ri-alarm-warning-line stat-icon"></i>
        </div>
        <div class="stat-card <?= $outOfStock > 0 ? 'border-danger' : '' ?>">
            <div class="stat-value text-red-600"><?= $outOfStock ?></div>
            <div class="stat-label">Out of Stock</div>
            <i class="ri-close-circle-line stat-icon"></i>
        </div>
        <?php if ($totalValue > 0): ?>
        <div class="stat-card">
            <div class="stat-value"><?= money($totalValue) ?></div>
            <div class="stat-label">Total Value</div>
            <i class="ri-money-dollar-circle-line stat-icon"></i>
        </div>
        <?php endif; ?>
    </div>

    <!-- Alerts Banner -->
    <?php if ($outOfStock > 0 || $lowStock > 0): ?>
    <div class="mb-4 space-y-2">
        <?php foreach ($items as $item): ?>
        <?php if ($item['quantity'] <= 0): ?>
        <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 px-4 py-2.5 rounded-xl text-sm">
            <i class="ri-close-circle-fill text-red-500 flex-shrink-0"></i>
            <span class="font-medium flex-1"><?= e($item['name']) ?></span>
            <span class="font-bold">0 <?= e($item['unit']) ?></span>
            <button onclick="openRestock(<?= $item['id'] ?>, '<?= e(addslashes($item['name'])) ?>')" class="btn btn-sm bg-red-100 hover:bg-red-200 text-red-700 border-0 ml-2">
                <i class="ri-refresh-line"></i> Restock
            </button>
        </div>
        <?php elseif ($item['quantity'] <= $item['low_stock_threshold']): ?>
        <div class="flex items-center gap-3 bg-amber-50 border border-amber-200 text-amber-700 px-4 py-2.5 rounded-xl text-sm">
            <i class="ri-alarm-warning-fill text-amber-500 flex-shrink-0"></i>
            <span class="font-medium flex-1"><?= e($item['name']) ?></span>
            <span><?= e($item['quantity']) ?> / <?= e($item['low_stock_threshold']) ?> <?= e($item['unit']) ?></span>
            <button onclick="openRestock(<?= $item['id'] ?>, '<?= e(addslashes($item['name'])) ?>')" class="btn btn-sm bg-amber-100 hover:bg-amber-200 text-amber-700 border-0 ml-2">
                <i class="ri-refresh-line"></i> Restock
            </button>
        </div>
        <?php endif; ?>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>

    <!-- Search + Filter Tabs -->
    <div class="flex flex-col sm:flex-row gap-3 mb-4">
        <div class="relative flex-1">
            <i class="ri-search-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
            <input type="text" id="stockSearch" placeholder="Search inventory…" class="form-input pl-9" oninput="filterStock()">
        </div>
        <div class="flex gap-1">
            <button class="view-filter active" data-filter="all" onclick="setView(this, 'all')">All</button>
            <button class="view-filter" data-filter="low" onclick="setView(this, 'low')">Low Stock</button>
            <button class="view-filter" data-filter="out" onclick="setView(this, 'out')">Out</button>
        </div>
    </div>

    <!-- Stock Grid -->
    <div id="stockGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
        <?php foreach ($items as $item):
            $pct      = $item['low_stock_threshold'] > 0 ? min(100, round(($item['quantity'] / $item['low_stock_threshold']) * 100)) : 100;
            $isLow    = $item['quantity'] <= $item['low_stock_threshold'] && $item['quantity'] > 0;
            $isOut    = $item['quantity'] <= 0;
            $barColor = $isOut ? 'bg-red-500' : ($isLow ? 'bg-amber-500' : 'bg-green-500');
            $barWidth = $isOut ? 5 : ($isLow ? max(5, $pct) : min(100, $pct));
            $statusClass = $isOut ? 'out-of-stock' : ($isLow ? 'low-stock' : '');
        ?>
        <div class="card stock-card <?= $isOut ? 'border-l-4 border-l-red-500' : ($isLow ? 'border-l-4 border-l-amber-500' : '') ?> <?= $statusClass ?>" data-name="<?= e(strtolower($item['name'])) ?>">
            <div class="flex items-start justify-between mb-2 gap-2">
                <div class="flex-1 min-w-0">
                    <h4 class="font-semibold truncate"><?= e($item['name']) ?></h4>
                    <?php if ($item['supplier_name']): ?>
                    <p class="text-xs text-gray-400 truncate"><i class="ri-truck-line mr-0.5"></i> <?= e($item['supplier_name']) ?></p>
                    <?php endif; ?>
                </div>
                <div class="text-right flex-shrink-0">
                    <div class="text-lg font-bold <?= $isOut ? 'text-red-600' : ($isLow ? 'text-amber-600' : 'text-green-600') ?>">
                        <?= $isOut ? '0' : e($item['quantity']) ?>
                    </div>
                    <div class="text-xs text-gray-400"><?= e($item['unit']) ?></div>
                </div>
            </div>
            <div class="w-full bg-gray-100 rounded-full h-1.5 mb-2">
                <div class="h-1.5 rounded-full <?= $barColor ?> transition-all" style="width:<?= $barWidth ?>%"></div>
            </div>
            <div class="flex items-center justify-between text-xs mb-3">
                <span class="<?= $isOut ? 'text-red-500 font-medium' : ($isLow ? 'text-amber-500 font-medium' : 'text-gray-400') ?>">
                    <?php if ($isOut): ?>⚠ Out of stock
                    <?php elseif ($isLow): ?>⚠ Alert at <?= e($item['low_stock_threshold']) ?> <?= e($item['unit']) ?>
                    <?php else: ?>Threshold: <?= e($item['low_stock_threshold']) ?> <?= e($item['unit']) ?>
                    <?php endif; ?>
                </span>
                <?php if ($item['cost_price']): ?>
                <span class="text-gray-400"><?= money($item['cost_price']) ?>/<?= e($item['unit']) ?></span>
                <?php endif; ?>
            </div>
            <div class="flex gap-1">
                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <?php if (in_array($item['id'], $linkedInvIds)): ?>
                <span class="btn btn-ghost btn-sm text-green-500 cursor-default flex-1" title="Already linked to a menu item">
                    <i class="ri-check-line"></i> In Menu
                </span>
                <?php else: ?>
                <button onclick="openCreateMenu(<?= $item['id'] ?>, '<?= e(addslashes($item['name'])) ?>')"
                    class="btn btn-ghost btn-sm flex-1 text-purple-600 hover:text-purple-800">
                    <i class="ri-restaurant-line"></i> + Menu
                </button>
                <?php endif; ?>
                <?php endif; ?>
                <button onclick="openRestock(<?= $item['id'] ?>, '<?= e(addslashes($item['name'])) ?>')"
                    class="btn btn-ghost btn-sm flex-1 text-green-600 hover:text-green-800">
                    <i class="ri-refresh-line"></i> Restock
                </button>
                <button onclick="openAdjust(<?= $item['id'] ?>, '<?= e(addslashes($item['name'])) ?>')"
                    class="btn btn-ghost btn-sm flex-1 text-amber-600 hover:text-amber-800">
                    <i class="ri-exchange-line"></i> Adjust
                </button>
                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <button onclick="openEditItem(<?= htmlspecialchars(json_encode([
                    'id'        => $item['id'],
                    'name'      => $item['name'],
                    'unit'      => $item['unit'],
                    'supplier_id' => $item['supplier_id'],
                    'cost_price' => $item['cost_price'],
                    'threshold' => $item['low_stock_threshold'],
                ]), ENT_QUOTES) ?>)"
                    class="btn btn-ghost btn-sm text-blue-600">
                    <i class="ri-edit-line"></i>
                </button>
                <?php endif; ?>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
    <div id="noStockMatch" class="empty-state hidden">
        <i class="ri-search-line"></i>
        <p>No items match your search or filter</p>
    </div>

    <!-- Tabs: Transactions / Restock History -->
    <?php if (!empty($transactions) || !empty($restocks)): ?>
    <div class="mt-8">
        <div class="flex gap-1 mb-4 border-b border-gray-200">
            <button class="history-tab active" data-tab="transactions" onclick="switchTab('transactions')">
                <i class="ri-history-line"></i> Transactions
            </button>
            <button class="history-tab" data-tab="restocks" onclick="switchTab('restocks')">
                <i class="ri-refresh-line"></i> Restock History
            </button>
        </div>

        <div id="tab-transactions" class="history-panel active">
            <?php if ($transactions): ?>
            <div class="card p-0">
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr><th>Time</th><th>Item</th><th>Type</th><th>Qty</th><th>Note</th></tr>
                        </thead>
                        <tbody>
                            <?php foreach ($transactions as $txn):
                                $typeColor = match($txn['type']) {
                                    'in'     => 'bg-green-100 text-green-700 border-green-200',
                                    'out'    => 'bg-red-100 text-red-700 border-red-200',
                                    'adjust' => 'bg-blue-100 text-blue-700 border-blue-200',
                                    default  => 'bg-gray-100 text-gray-600 border-gray-200',
                                };
                                $sign = $txn['type'] === 'in' ? '+' : ($txn['type'] === 'out' ? '−' : '≈');
                            ?>
                            <tr>
                                <td class="text-xs text-gray-500 whitespace-nowrap"><?= date('d M H:i', strtotime($txn['created_at'])) ?></td>
                                <td class="font-medium"><?= e($txn['item_name']) ?></td>
                                <td><span class="badge border <?= $typeColor ?> text-xs"><?= e($txn['type']) ?></span></td>
                                <td class="font-semibold <?= $txn['type'] === 'in' ? 'text-green-600' : ($txn['type'] === 'out' ? 'text-red-600' : 'text-blue-600') ?>">
                                    <?= $sign ?><?= e($txn['quantity']) ?>
                                </td>
                                <td class="text-xs text-gray-500"><?= e($txn['note'] ?: '—') ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <?php else: ?>
            <div class="empty-state"><i class="ri-history-line"></i><p>No transactions yet</p></div>
            <?php endif; ?>
        </div>

        <div id="tab-restocks" class="history-panel">
            <?php if ($restocks): ?>
            <div class="card p-0">
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr><th>Time</th><th>Item</th><th>Qty</th><th>Supplier</th><th>Cost</th><th>By</th><th>Note</th></tr>
                        </thead>
                        <tbody>
                            <?php foreach ($restocks as $r): ?>
                            <tr>
                                <td class="text-xs text-gray-500 whitespace-nowrap"><?= date('d M H:i', strtotime($r['created_at'])) ?></td>
                                <td class="font-medium"><?= e($r['item_name']) ?></td>
                                <td class="font-semibold text-green-600">+<?= e($r['quantity']) ?></td>
                                <td class="text-sm"><?= e($r['supplier_name'] ?: '—') ?></td>
                                <td class="text-sm"><?= $r['total_cost'] ? money($r['total_cost']) : '—' ?></td>
                                <td class="text-sm text-gray-500"><?= e($r['user_name'] ?: '—') ?></td>
                                <td class="text-xs text-gray-500"><?= e($r['note'] ?: '—') ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <?php else: ?>
            <div class="empty-state"><i class="ri-refresh-line"></i><p>No restocks recorded yet — click <strong>Restock</strong> on any item</p></div>
            <?php endif; ?>
        </div>
    </div>
    <?php endif; ?>

    <?php else: ?>
    <div class="empty-state">
        <i class="ri-stock-line"></i>
        <p class="font-medium text-gray-700">No inventory items yet</p>
        <p class="text-sm mt-1">Add items to start tracking stock</p>
        <button onclick="document.getElementById('addItemModal').classList.remove('hidden')" class="btn btn-primary mt-4">Add Item</button>
    </div>
    <?php endif; ?>
</div>

<!-- Add Item Modal -->
<div id="addItemModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-add-box-line mr-1"></i> Add Inventory Item</h3>
            <button type="button" onclick="toggleModal('addItemModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="add_item">
            <?= csrfField() ?>
            <div class="space-y-3">
                <div><label class="form-label">Item Name <span class="text-red-500">*</span></label><input type="text" name="name" placeholder="e.g. Heineken Bottle" class="form-input" required></div>
                <div class="grid grid-cols-2 gap-3">
                    <div><label class="form-label">Initial Quantity <span class="text-red-500">*</span></label><input type="number" step="0.01" min="0" name="quantity" placeholder="0" class="form-input" required></div>
                    <div><label class="form-label">Unit <span class="text-red-500">*</span></label><input type="text" name="unit" placeholder="bottles / kg / pcs" class="form-input" value="pcs" required></div>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div><label class="form-label">Preferred Supplier</label>
                        <select name="supplier_id" class="form-select">
                            <option value="">None</option>
                            <?php foreach ($suppliers as $s): ?>
                            <option value="<?= $s['id'] ?>"><?= e($s['name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div><label class="form-label">Unit Cost (₦)</label><input type="number" step="0.01" min="0" name="cost_price" placeholder="0.00" class="form-input"></div>
                </div>
                <div><label class="form-label">Low Stock Alert At</label><input type="number" step="0.01" min="0" name="threshold" placeholder="10" class="form-input" value="10"></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Save</button>
                <button type="button" onclick="toggleModal('addItemModal')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Restock Modal -->
<div id="restockModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-refresh-line text-green-500 mr-1"></i> Restock: <span id="restockName" class="text-green-600"></span></h3>
            <button type="button" onclick="toggleModal('restockModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="restock">
            <?= csrfField() ?>
            <input type="hidden" name="id" id="restockId">
            <div class="space-y-3">
                <div><label class="form-label">Quantity to Add <span class="text-red-500">*</span></label><input type="number" step="0.01" min="0.01" name="quantity" placeholder="e.g. 24" class="form-input" required></div>
                <div><label class="form-label">Supplier</label>
                    <select name="supplier_id" class="form-select">
                        <option value="">No supplier (direct purchase)</option>
                        <?php foreach ($suppliers as $s): ?>
                        <option value="<?= $s['id'] ?>"><?= e($s['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div><label class="form-label">Unit Cost (₦) <span class="text-gray-400 font-normal">(optional)</span></label><input type="number" step="0.01" min="0" name="unit_cost" placeholder="0.00" class="form-input"></div>
                    <div><label class="form-label">Total Cost</label><input type="text" id="restockTotalCost" class="form-input bg-gray-50 text-gray-500" readonly placeholder="Auto-calculated"></div>
                </div>
                <div><label class="form-label">Note <span class="text-gray-400 font-normal">(optional)</span></label><input type="text" name="note" placeholder="e.g. Weekly delivery" class="form-input"></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-success flex-1"><i class="ri-check-line"></i> Restock</button>
                <button type="button" onclick="toggleModal('restockModal')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Adjust Stock Modal -->
<div id="adjustModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-exchange-line mr-1"></i> Adjust: <span id="adjustName" class="text-amber-600"></span></h3>
            <button type="button" onclick="toggleModal('adjustModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="adjust_stock">
            <?= csrfField() ?>
            <input type="hidden" name="id" id="adjustId">
            <div class="space-y-3">
                <div>
                    <label class="form-label">Adjustment Type</label>
                    <select name="adj_type" class="form-select" required>
                        <option value="in">➕ Add Stock (In)</option>
                        <option value="out">➖ Remove Stock (Out / Wastage)</option>
                        <option value="adjust">🔄 Set Exact Quantity</option>
                    </select>
                </div>
                <div><label class="form-label">Quantity</label><input type="number" step="0.01" min="0" name="quantity" placeholder="0" class="form-input" required></div>
                <div><label class="form-label">Reason <span class="text-gray-400 font-normal">(optional)</span></label><input type="text" name="note" placeholder="e.g. Damaged goods, miscount" class="form-input"></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Save</button>
                <button type="button" onclick="toggleModal('adjustModal')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Item Modal -->
<div id="editItemModal" class="modal-overlay hidden">
    <div class="modal-content max-w-md">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-edit-line mr-1"></i> Edit Item</h3>
            <button type="button" onclick="toggleModal('editItemModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="edit_item">
            <?= csrfField() ?>
            <input type="hidden" name="id" id="editItemId">
            <div class="space-y-3">
                <div><label class="form-label">Item Name</label><input type="text" name="name" id="editItemName" class="form-input" required></div>
                <div><label class="form-label">Unit</label><input type="text" name="unit" id="editItemUnit" class="form-input" required></div>
                <div class="grid grid-cols-2 gap-3">
                    <div><label class="form-label">Supplier</label>
                        <select name="supplier_id" id="editItemSupplier" class="form-select">
                            <option value="">None</option>
                            <?php foreach ($suppliers as $s): ?>
                            <option value="<?= $s['id'] ?>"><?= e($s['name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div><label class="form-label">Unit Cost (₦)</label><input type="number" step="0.01" min="0" name="cost_price" id="editItemCost" class="form-input"></div>
                </div>
                <div><label class="form-label">Low Stock Alert At</label><input type="number" step="0.01" min="0" name="threshold" id="editItemThreshold" class="form-input" required></div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Save Changes</button>
                <button type="button" onclick="toggleModal('editItemModal')" class="btn btn-outline">Cancel</button>
</div>
</form>
</div>
</div>

<!-- Create Menu Item Modal -->
<div id="createMenuModal" class="modal-overlay hidden">
<div class="modal-content max-w-sm">
<div class="modal-header">
    <h3 class="modal-title"><i class="ri-restaurant-line text-purple-500 mr-1"></i> Add to Menu: <span id="createMenuName" class="text-purple-600"></span></h3>
    <button type="button" onclick="toggleModal('createMenuModal')" class="modal-close"><i class="ri-close-line"></i></button>
</div>
<form method="POST">
    <input type="hidden" name="action" value="create_menu_item">
    <?= csrfField() ?>
    <input type="hidden" name="inventory_id" id="createMenuInvId">
    <input type="hidden" name="name" id="createMenuItemName">
    <div class="space-y-3">
        <div>
            <label class="form-label">Menu Category <span class="text-red-500">*</span></label>
            <select name="category_id" class="form-select" required>
                <option value="">Select category…</option>
                <?php foreach ($categories as $c): ?>
                <option value="<?= $c['id'] ?>"><?= e($c['name']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div>
            <label class="form-label">Selling Price <span class="text-red-500">*</span></label>
            <input type="number" step="0.01" min="0.01" name="price" placeholder="e.g. 5.00" class="form-input" required>
            <p class="text-xs text-gray-400 mt-1">A <strong>1:1 inventory mapping</strong> will be created automatically (1 sale = 1 stock deducted).</p>
        </div>
    </div>
    <div class="flex gap-2 mt-4">
        <button type="submit" class="btn btn-primary flex-1"><i class="ri-check-line"></i> Create Menu Item</button>
        <button type="button" onclick="toggleModal('createMenuModal')" class="btn btn-outline">Cancel</button>
    </div>
</form>
</div>
</div>

<script>
function toggleModal(id) { document.getElementById(id).classList.toggle('hidden'); }

function openRestock(id, name) {
    document.getElementById('restockId').value = id;
    document.getElementById('restockName').textContent = name;
    document.getElementById('restockModal').classList.remove('hidden');
}

function openAdjust(id, name) {
    document.getElementById('adjustId').value = id;
    document.getElementById('adjustName').textContent = name;
    document.getElementById('adjustModal').classList.remove('hidden');
}

function openCreateMenu(id, name) {
    document.getElementById('createMenuInvId').value = id;
    document.getElementById('createMenuName').textContent = name;
    document.getElementById('createMenuItemName').value = name;
    document.getElementById('createMenuModal').classList.remove('hidden');
}

function openEditItem(data) {
    document.getElementById('editItemId').value        = data.id;
    document.getElementById('editItemName').value      = data.name;
    document.getElementById('editItemUnit').value      = data.unit;
    document.getElementById('editItemSupplier').value  = data.supplier_id || '';
    document.getElementById('editItemCost').value      = data.cost_price || '';
    document.getElementById('editItemThreshold').value = data.threshold;
    document.getElementById('editItemModal').classList.remove('hidden');
}

function filterStock() {
    var q = (document.getElementById('stockSearch').value || '').toLowerCase();
    var cards = document.querySelectorAll('.stock-card');
    var visible = 0;
    cards.forEach(function(c) {
        var match = !q || (c.dataset.name || '').indexOf(q) !== -1;
        c.style.display = match ? '' : 'none';
        if (match) visible++;
    });
    document.getElementById('noStockMatch').classList.toggle('hidden', visible > 0);
}

function setView(btn, filter) {
    document.querySelectorAll('.view-filter').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    var cards = document.querySelectorAll('.stock-card');
    var visible = 0;
    cards.forEach(function(c) {
        if (filter === 'all') { c.style.display = ''; visible++; return; }
        var isOut = c.classList.contains('out-of-stock');
        var isLow = c.classList.contains('low-stock');
        var match = (filter === 'out' && isOut) || (filter === 'low' && (isLow || isOut));
        c.style.display = match ? '' : 'none';
        if (match) visible++;
    });
    document.getElementById('noStockMatch').classList.toggle('hidden', visible > 0);
}

function switchTab(tab) {
    document.querySelectorAll('.history-tab').forEach(function(t) { t.classList.remove('active'); });
    document.querySelectorAll('.history-panel').forEach(function(p) { p.classList.remove('active'); });
    document.querySelector('.history-tab[data-tab="' + tab + '"]').classList.add('active');
    document.getElementById('tab-' + tab).classList.add('active');
}

// Auto-calculate total cost in restock modal
document.addEventListener('input', function(e) {
    if (e.target.matches('#restockModal input[name="quantity"]') || e.target.matches('#restockModal input[name="unit_cost"]')) {
        var qty = parseFloat(document.querySelector('#restockModal input[name="quantity"]').value) || 0;
        var cost = parseFloat(document.querySelector('#restockModal input[name="unit_cost"]').value) || 0;
        document.getElementById('restockTotalCost').value = qty > 0 && cost > 0 ? '₦' + (qty * cost).toLocaleString('en-US', { minimumFractionDigits: 2 }) : '';
    }
});
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>