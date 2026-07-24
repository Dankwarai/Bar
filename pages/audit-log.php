<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin');
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$page    = max(1, (int)($_GET['page'] ?? 1));
$perPage = 50;
$offset  = ($page - 1) * $perPage;

$action  = $_GET['action_filter'] ?? '';
$search  = trim($_GET['q'] ?? '');

$where  = [];
$params = [];

if ($action) {
    $where[]  = "action = ?";
    $params[] = $action;
}
if ($search) {
    $where[]  = "(target LIKE ? OR details LIKE ? OR user_name LIKE ?)";
    $params[] = "%{$search}%";
    $params[] = "%{$search}%";
    $params[] = "%{$search}%";
}

$whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

$countStmt = db()->prepare("SELECT COUNT(*) FROM bar_audit_log {$whereClause}");
$countStmt->execute($params);
$total = (int)$countStmt->fetchColumn();
$totalPages = max(1, ceil($total / $perPage));

$logStmt = db()->prepare("
    SELECT * FROM bar_audit_log
    {$whereClause}
    ORDER BY created_at DESC
    LIMIT {$perPage} OFFSET {$offset}
");
$logStmt->execute($params);
$logs = $logStmt->fetchAll();

// Distinct action types for filter dropdown
$actionTypes = db()->query("SELECT DISTINCT action FROM bar_audit_log ORDER BY action")->fetchAll(PDO::FETCH_COLUMN);

$actionColors = [
    'checkout'       => 'bg-green-100 text-green-700 border-green-200',
    'void_order'     => 'bg-red-100 text-red-700 border-red-200',
    'refund'         => 'bg-orange-100 text-orange-700 border-orange-200',
    'stock_adjust'   => 'bg-blue-100 text-blue-700 border-blue-200',
    'apply_discount' => 'bg-purple-100 text-purple-700 border-purple-200',
    'shift_open'     => 'bg-teal-100 text-teal-700 border-teal-200',
    'shift_close'    => 'bg-teal-100 text-teal-700 border-teal-200',
    'accept_order'   => 'bg-amber-100 text-amber-700 border-amber-200',
    'create_order'   => 'bg-gray-100 text-gray-700 border-gray-200',
    'menu_add_item'  => 'bg-indigo-100 text-indigo-700 border-indigo-200',
    'menu_edit_item' => 'bg-indigo-100 text-indigo-700 border-indigo-200',
];
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-shield-check-line text-amber-500 mr-1"></i> Audit Log</h2>
        <span class="text-xs text-gray-400"><?= number_format($total) ?> entries</span>
    </div>

    <!-- Filters -->
    <form method="GET" class="card mb-4 flex flex-wrap gap-3 items-end">
        <div class="flex-1 min-w-[180px]">
            <label class="form-label">Search</label>
            <input type="text" name="q" value="<?= e($search) ?>" class="form-input" placeholder="user, target, details…">
        </div>
        <div>
            <label class="form-label">Action</label>
            <select name="action_filter" class="form-select">
                <option value="">All actions</option>
                <?php foreach ($actionTypes as $at): ?>
                <option value="<?= e($at) ?>" <?= $action === $at ? 'selected' : '' ?>><?= e($at) ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="flex gap-2">
            <button type="submit" class="btn btn-primary"><i class="ri-filter-line"></i> Filter</button>
            <?php if ($search || $action): ?>
            <a href="/bar/pages/audit-log.php" class="btn btn-outline">Clear</a>
            <?php endif; ?>
        </div>
    </form>

    <div class="card p-0">
        <?php if (empty($logs)): ?>
        <div class="empty-state p-8">
            <i class="ri-shield-check-line"></i>
            <p class="font-medium text-gray-700">No audit entries found</p>
        </div>
        <?php else: ?>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Time</th><th>User</th><th>Action</th><th>Target</th><th>Details</th><th>IP</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($logs as $log):
                        $color = $actionColors[$log['action']] ?? 'bg-gray-100 text-gray-600 border-gray-200';
                    ?>
                    <tr>
                        <td class="text-xs text-gray-500 whitespace-nowrap">
                            <?= date('d M H:i:s', strtotime($log['created_at'])) ?>
                        </td>
                        <td class="font-medium text-sm"><?= e($log['user_name'] ?: '—') ?></td>
                        <td>
                            <span class="badge border <?= $color ?> text-xs whitespace-nowrap">
                                <?= e($log['action']) ?>
                            </span>
                        </td>
                        <td class="text-sm"><?= e($log['target'] ?: '—') ?></td>
                        <td class="text-xs text-gray-500 max-w-xs truncate" title="<?= e($log['details']) ?>">
                            <?= e($log['details'] ?: '—') ?>
                        </td>
                        <td class="text-xs text-gray-400 font-mono"><?= e($log['ip'] ?: '—') ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <?php if ($totalPages > 1): ?>
        <div class="flex items-center justify-between px-4 py-3 border-t text-sm">
            <span class="text-gray-500">
                Page <?= $page ?> of <?= $totalPages ?> &nbsp;·&nbsp; <?= number_format($total) ?> entries
            </span>
            <div class="flex gap-1">
                <?php if ($page > 1): ?>
                <a href="?page=<?= $page - 1 ?>&action_filter=<?= e($action) ?>&q=<?= urlencode($search) ?>" class="btn btn-outline btn-sm">← Prev</a>
                <?php endif; ?>
                <?php if ($page < $totalPages): ?>
                <a href="?page=<?= $page + 1 ?>&action_filter=<?= e($action) ?>&q=<?= urlencode($search) ?>" class="btn btn-outline btn-sm">Next →</a>
                <?php endif; ?>
            </div>
        </div>
        <?php endif; ?>
        <?php endif; ?>
    </div>
</div>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
