<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
if (!defined('BAR_HEADER_LOADED')) {
    $_standalone = true;
    require __DIR__ . '/../includes/header.php';
} else {
    $_standalone = false;
}

// AJAX endpoint — return live stats as JSON
if (isset($_GET['ajax']) && $_GET['ajax'] === 'stats') {
    $activeOrders = (int)db()->query("SELECT COUNT(*) FROM bar_orders WHERE status NOT IN ('closed')")->fetchColumn();
    $pendingCust  = (int)db()->query("SELECT COUNT(*) FROM bar_orders WHERE status = 'pending' AND source = 'customer'")->fetchColumn();
    $todayTotal   = (float)db()->query("SELECT COALESCE(SUM(amount),0) FROM bar_payments WHERE DATE(created_at) = CURDATE()")->fetchColumn();
    $lowCount     = (int)db()->query("SELECT COUNT(*) FROM bar_inventory WHERE quantity <= low_stock_threshold")->fetchColumn();
    $occupiedCount= (int)db()->query("SELECT COUNT(*) FROM bar_tables WHERE status = 'occupied'")->fetchColumn();

    echo json_encode([
        'active_orders'  => $activeOrders,
        'pending_cust'   => $pendingCust,
        'today_total'    => '₦' . number_format($todayTotal, 2),
        'low_stock'      => $lowCount,
        'occupied_tables'=> $occupiedCount,
    ]);
    exit;
}

// Initial PHP values
$activeCount   = (int)db()->query("SELECT COUNT(*) FROM bar_orders WHERE status NOT IN ('closed')")->fetchColumn();
$pendingCust   = (int)db()->query("SELECT COUNT(*) FROM bar_orders WHERE status = 'pending' AND source = 'customer'")->fetchColumn();
$todayTotal    = (float)db()->query("SELECT COALESCE(SUM(amount),0) FROM bar_payments WHERE DATE(created_at) = CURDATE()")->fetchColumn();
$lowCount      = (int)db()->query("SELECT COUNT(*) FROM bar_inventory WHERE quantity <= low_stock_threshold")->fetchColumn();
$occupiedCount = (int)db()->query("SELECT COUNT(*) FROM bar_tables WHERE status = 'occupied'")->fetchColumn();

$recentOrders = db()->query("
    SELECT o.*, t.number AS table_number, u.name AS staff_name
    FROM bar_orders o
    LEFT JOIN bar_tables t ON t.id = o.table_id
    LEFT JOIN bar_users u ON u.id = o.user_id
    ORDER BY o.created_at DESC LIMIT 10
")->fetchAll();
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <div>
            <h2 class="page-title">Dashboard</h2>
            <p class="text-xs text-gray-400 mt-0.5">
                Auto-refreshes every 30s &nbsp;|&nbsp; Last: <span id="lastUpdate"><?= date('H:i:s') ?></span>
            </p>
        </div>
        <div class="flex gap-2">
            <?php if ($pendingCust > 0): ?>
            <a href="/bar/pages/pos.php" class="btn btn-accent btn-sm" id="pendingBadge">
                <i class="ri-alarm-warning-line"></i>
                <span id="pendingCount"><?= $pendingCust ?></span> Pending QR Order<?= $pendingCust !== 1 ? 's' : '' ?>
            </a>
            <?php else: ?>
            <a href="/bar/pages/pos.php" class="btn btn-accent btn-sm hidden" id="pendingBadge">
                <i class="ri-alarm-warning-line"></i>
                <span id="pendingCount">0</span> Pending QR Orders
            </a>
            <?php endif; ?>
            <a href="/bar/pages/kitchen.php" class="btn btn-outline btn-sm">
                <i class="ri-fire-line"></i> Kitchen
            </a>
        </div>
    </div>

    <!-- Stats grid -->
    <div class="stats-grid">
        <div class="stat-card border-accent">
            <i class="ri-shopping-bag-3-line stat-icon"></i>
            <p class="stat-value" id="stat-active"><?= $activeCount ?></p>
            <p class="stat-label">Active Orders</p>
        </div>
        <div class="stat-card border-success">
            <i class="ri-money-dollar-circle-line stat-icon"></i>
            <p class="stat-value" id="stat-sales"><?= money($todayTotal) ?></p>
            <p class="stat-label">Today's Sales</p>
        </div>
        <div class="stat-card border-info">
            <i class="ri-table-line stat-icon"></i>
            <p class="stat-value" id="stat-tables"><?= $occupiedCount ?></p>
            <p class="stat-label">Occupied Tables</p>
        </div>
        <div class="stat-card border-danger">
            <i class="ri-alert-line stat-icon"></i>
            <p class="stat-value" id="stat-lowstock"><?= $lowCount ?></p>
            <p class="stat-label">Low Stock Items</p>
        </div>
    </div>

    <!-- Recent Orders -->
    <div class="card">
        <div class="flex items-center justify-between mb-4">
            <h3 class="font-semibold"><i class="ri-file-list-3-line text-amber-500 mr-1"></i> Recent Orders</h3>
            <a href="/bar/pages/orders.php" class="text-xs text-amber-600 hover:underline">View all →</a>
        </div>
        <?php if (empty($recentOrders)): ?>
        <div class="empty-state"><i class="ri-file-list-3-line"></i><p>No orders yet.</p></div>
        <?php else: ?>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Table</th><th>Staff</th><th>Total</th><th>Status</th><th>Source</th><th>Time</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($recentOrders as $o): ?>
                    <tr>
                        <td><?= e($o['table_number']) ?></td>
                        <td><?= e($o['staff_name'] ?? '—') ?></td>
                        <td class="font-medium"><?= money($o['total']) ?></td>
                        <td><span class="badge badge-<?= e($o['status']) ?>"><?= e($o['status']) ?></span></td>
                        <td><?= e($o['source']) ?></td>
                        <td class="text-sm text-gray-500"><?= date('H:i', strtotime($o['created_at'])) ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php endif; ?>
    </div>
</div>

<script>
var DASHBOARD_STATS_URL = '/bar/pages/dashboard.php?ajax=stats';
var refreshTimer;

function refreshDashboard() {
    fetch(DASHBOARD_STATS_URL)
    .then(function(r) { return r.json(); })
    .then(function(d) {
        document.getElementById('stat-active').textContent   = d.active_orders;
        document.getElementById('stat-sales').textContent    = d.today_total;
        document.getElementById('stat-tables').textContent   = d.occupied_tables;
        document.getElementById('stat-lowstock').textContent = d.low_stock;
        document.getElementById('lastUpdate').textContent    = new Date().toLocaleTimeString('en-GB');

        // Pending customer orders badge
        var badge = document.getElementById('pendingBadge');
        var countEl = document.getElementById('pendingCount');
        if (d.pending_cust > 0) {
            countEl.textContent = d.pending_cust;
            badge.innerHTML = '<i class="ri-alarm-warning-line"></i> ' + d.pending_cust + ' Pending QR Order' + (d.pending_cust !== 1 ? 's' : '');
            badge.classList.remove('hidden');
            badge.classList.add('btn-accent');
        } else {
            badge.classList.add('hidden');
        }
    })
    .catch(function() { /* silent — stale data is fine */ });
}

// Auto-refresh every 30 seconds
document.addEventListener('DOMContentLoaded', function() {
    refreshTimer = setInterval(refreshDashboard, 30000);
});
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
