<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$period   = $_GET['period'] ?? 'today';
$dateFrom = $_GET['from']   ?? '';
$dateTo   = $_GET['to']     ?? '';

// Build date filter
if ($dateFrom && $dateTo) {
    $dateFilter  = "DATE(p.created_at) BETWEEN ? AND ?";
    $dateParams  = [$dateFrom, $dateTo];
    $labelSuffix = "$dateFrom → $dateTo";
} else {
    $dateParams = [];
    switch ($period) {
        case 'week':
            $dateFilter  = "YEARWEEK(p.created_at, 1) = YEARWEEK(CURDATE(), 1)";
            $labelSuffix = 'This Week';
            break;
        case 'month':
            $dateFilter  = "MONTH(p.created_at) = MONTH(CURDATE()) AND YEAR(p.created_at) = YEAR(CURDATE())";
            $labelSuffix = 'This Month';
            break;
        default:
            $period      = 'today';
            $dateFilter  = "DATE(p.created_at) = CURDATE()";
            $labelSuffix = 'Today';
    }
}

// ── CSV export ─────────────────────────────────────────────────────────────────
if (isset($_GET['export'])) {
    $type = $_GET['export'];

    if ($type === 'sales') {
        $sql = "SELECT o.id AS order_id, t.number AS table_no, u.name AS staff,
                       p.method, p.amount, p.created_at
                FROM bar_payments p
                JOIN bar_orders o ON o.id = p.order_id
                LEFT JOIN bar_tables t ON t.id = o.table_id
                LEFT JOIN bar_users u ON u.id = o.user_id
                WHERE $dateFilter
                ORDER BY p.created_at DESC";
        $stmt = db()->prepare($sql);
        $stmt->execute($dateParams);
        $rows = $stmt->fetchAll();
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="sales_' . $labelSuffix . '.csv"');
        $out = fopen('php://output', 'w');
        fputcsv($out, ['Order ID', 'Table', 'Staff', 'Payment Method', 'Amount', 'Date/Time']);
        foreach ($rows as $row) {
            fputcsv($out, [$row['order_id'], $row['table_no'], $row['staff'] ?? '—', $row['method'], $row['amount'], $row['created_at']]);
        }
        fclose($out);
        exit;
    }

    if ($type === 'items') {
        $itemDateFilter = str_replace('p.created_at', 'o.created_at', $dateFilter);
        $sql = "SELECT mi.name, SUM(oi.quantity) AS qty_sold,
                       SUM(oi.quantity * oi.unit_price) AS revenue,
                       (
                           SELECT CASE
                               WHEN COUNT(*) = 0 THEN NULL
                               WHEN SUM(CASE WHEN inv.cost_price IS NULL THEN 1 ELSE 0 END) > 0 THEN NULL
                               ELSE SUM(bmi.qty_per_sale * inv.cost_price)
                           END
                           FROM bar_menu_inventory bmi
                           JOIN bar_inventory inv ON inv.id = bmi.inventory_id
                           WHERE bmi.menu_item_id = mi.id
                       ) AS unit_cost
                FROM bar_order_items oi
                JOIN bar_orders o ON o.id = oi.order_id
                JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
                WHERE $itemDateFilter
                GROUP BY mi.id, mi.name
                ORDER BY qty_sold DESC";
        $stmt = db()->prepare($sql);
        $stmt->execute($dateParams);
        $rows = $stmt->fetchAll();
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="top_items_' . $labelSuffix . '.csv"');
        $out = fopen('php://output', 'w');
        fputcsv($out, ['Item', 'Qty Sold', 'Revenue', 'Cost (COGS)', 'Margin', 'Margin %']);
        foreach ($rows as $row) {
            $cost = $row['unit_cost'] !== null ? round($row['unit_cost'] * $row['qty_sold'], 2) : '';
            $margin = $cost !== '' ? round($row['revenue'] - $cost, 2) : '';
            $marginPct = ($cost !== '' && (float)$row['revenue'] > 0) ? round($margin / $row['revenue'] * 100, 1) . '%' : '';
            fputcsv($out, [$row['name'], $row['qty_sold'], $row['revenue'], $cost, $margin, $marginPct]);
        }
        fclose($out);
        exit;
    }

    if ($type === 'staff') {
        $sql = "SELECT u.name AS staff,
                       COUNT(DISTINCT o.id) AS orders,
                       COALESCE(SUM(p.amount), 0) AS total
                FROM bar_payments p
                JOIN bar_orders o ON o.id = p.order_id
                LEFT JOIN bar_users u ON u.id = o.user_id
                WHERE $dateFilter
                GROUP BY o.user_id, u.name
                ORDER BY total DESC";
        $stmt = db()->prepare($sql);
        $stmt->execute($dateParams);
        $rows = $stmt->fetchAll();
        header('Content-Type: text/csv');
        header('Content-Disposition: attachment; filename="staff_sales_' . $labelSuffix . '.csv"');
        $out = fopen('php://output', 'w');
        fputcsv($out, ['Staff', 'Orders', 'Total Sales']);
        foreach ($rows as $row) {
            fputcsv($out, [$row['staff'] ?? '—', $row['orders'], $row['total']]);
        }
        fclose($out);
        exit;
    }
}

// ── Regular page ──────────────────────────────────────────────────────────────
if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

// Sales by payment method
$sales = db()->prepare("
    SELECT COALESCE(SUM(p.amount), 0) AS total, COUNT(*) AS count, p.method
    FROM bar_payments p
    WHERE $dateFilter
    GROUP BY p.method
");
$sales->execute($dateParams);
$byMethod = $sales->fetchAll();

$totalSales = array_sum(array_column($byMethod, 'total'));
$totalCount = array_sum(array_column($byMethod, 'count'));

// Refunds issued in this period (by when the refund happened, not the original sale)
$refundDateFilter = str_replace('p.created_at', 'r.created_at', $dateFilter);
$refundStmt = db()->prepare("SELECT COALESCE(SUM(amount), 0) AS total, COUNT(*) AS count FROM bar_refunds r WHERE $refundDateFilter");
$refundStmt->execute($dateParams);
$refundRow    = $refundStmt->fetch();
$totalRefunds = (float)$refundRow['total'];
$refundCount  = (int)$refundRow['count'];
$netSales     = $totalSales - $totalRefunds;

// Tax breakdown — use order tax_amount column
$orderDateFilter = str_replace('p.created_at', 'o.created_at', $dateFilter);
$taxData = db()->prepare("
    SELECT COALESCE(SUM(o.subtotal), 0) AS total_subtotal,
           COALESCE(SUM(o.tax_amount), 0) AS total_tax
    FROM bar_orders o
    WHERE o.paid = 1 AND $orderDateFilter
");
$taxData->execute($dateParams);
$taxRow = $taxData->fetch();

// Top items
$itemDateFilter = str_replace('p.created_at', 'o.created_at', $dateFilter);
$topItems = db()->prepare("
    SELECT mi.name, SUM(oi.quantity) AS qty, SUM(oi.quantity * oi.unit_price) AS total
    FROM bar_order_items oi
    JOIN bar_orders o ON o.id = oi.order_id
    JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
    WHERE $itemDateFilter
    GROUP BY mi.id, mi.name
    ORDER BY qty DESC LIMIT 10
");
$topItems->execute($dateParams);
$topItems = $topItems->fetchAll();

// Cost of goods sold / margin — only computable for items whose full inventory
// mapping has a cost_price set; items with no mapping (or an incomplete one)
// show as "cost unknown" rather than being assumed to cost nothing.
$cogsStmt = db()->prepare("
    SELECT
        mi.id, mi.name,
        SUM(oi.quantity) AS qty,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        (
            SELECT CASE
                WHEN COUNT(*) = 0 THEN NULL
                WHEN SUM(CASE WHEN inv.cost_price IS NULL THEN 1 ELSE 0 END) > 0 THEN NULL
                ELSE SUM(bmi.qty_per_sale * inv.cost_price)
            END
            FROM bar_menu_inventory bmi
            JOIN bar_inventory inv ON inv.id = bmi.inventory_id
            WHERE bmi.menu_item_id = mi.id
        ) AS unit_cost
    FROM bar_order_items oi
    JOIN bar_orders o ON o.id = oi.order_id
    JOIN bar_menu_items mi ON mi.id = oi.menu_item_id
    WHERE $itemDateFilter
    GROUP BY mi.id, mi.name
    ORDER BY revenue DESC
");
$cogsStmt->execute($dateParams);
$cogsItems = $cogsStmt->fetchAll();

$totalCogs        = 0.0;
$itemRevenueTotal = 0.0;
$hasCostData      = false;
foreach ($cogsItems as &$ci) {
    $itemRevenueTotal += (float)$ci['revenue'];
    if ($ci['unit_cost'] !== null) {
        $ci['cost']       = (float)$ci['unit_cost'] * (float)$ci['qty'];
        $ci['margin']      = (float)$ci['revenue'] - $ci['cost'];
        $ci['margin_pct']  = (float)$ci['revenue'] > 0 ? round($ci['margin'] / (float)$ci['revenue'] * 100, 1) : null;
        $totalCogs += $ci['cost'];
        $hasCostData = true;
    } else {
        $ci['cost'] = $ci['margin'] = $ci['margin_pct'] = null;
    }
}
unset($ci);
$grossProfit    = $itemRevenueTotal - $totalCogs;
$grossMarginPct = $itemRevenueTotal > 0 ? round($grossProfit / $itemRevenueTotal * 100, 1) : null;

// Per-staff sales
$staffSales = db()->prepare("
    SELECT u.name AS staff_name,
           u.id   AS staff_id,
           COUNT(DISTINCT o.id)         AS order_count,
           COALESCE(SUM(p.amount), 0)   AS total_sales,
           COALESCE(AVG(p.amount), 0)   AS avg_order
    FROM bar_payments p
    JOIN bar_orders o ON o.id = p.order_id
    LEFT JOIN bar_users u ON u.id = o.user_id
    WHERE $dateFilter
    GROUP BY o.user_id, u.name
    ORDER BY total_sales DESC
");
$staffSales->execute($dateParams);
$staffSales = $staffSales->fetchAll();

function exportUrl(string $type, string $period, string $from, string $to): string {
    $q = ['export' => $type, 'period' => $period];
    if ($from && $to) { $q['from'] = $from; $q['to'] = $to; }
    return '/bar/pages/reports.php?' . http_build_query($q);
}
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-bar-chart-line text-amber-500 mr-1"></i> Reports</h2>
        <div class="flex gap-2 flex-wrap">
            <a href="/bar/pages/reports.php?period=today"  class="btn btn-sm <?= $period === 'today' && !$dateFrom ? 'btn-primary' : 'btn-outline' ?>">Today</a>
            <a href="/bar/pages/reports.php?period=week"   class="btn btn-sm <?= $period === 'week'  && !$dateFrom ? 'btn-primary' : 'btn-outline' ?>">This Week</a>
            <a href="/bar/pages/reports.php?period=month"  class="btn btn-sm <?= $period === 'month' && !$dateFrom ? 'btn-primary' : 'btn-outline' ?>">This Month</a>
        </div>
    </div>

    <!-- Custom Date Range -->
    <div class="card mb-4">
        <form method="GET" class="flex flex-wrap items-end gap-3">
            <input type="hidden" name="period" value="custom">
            <div>
                <label class="form-label">From</label>
                <input type="date" name="from" value="<?= e($dateFrom) ?>" class="form-input" required>
            </div>
            <div>
                <label class="form-label">To</label>
                <input type="date" name="to" value="<?= e($dateTo ?: date('Y-m-d')) ?>" class="form-input" required>
            </div>
            <button type="submit" class="btn btn-primary"><i class="ri-filter-line"></i> Apply Range</button>
            <?php if ($dateFrom): ?>
            <a href="/bar/pages/reports.php" class="btn btn-outline">Clear</a>
            <?php endif; ?>
        </form>
    </div>

    <!-- Summary stats -->
    <div class="stats-grid mb-4">
        <div class="stat-card border-accent">
            <i class="ri-money-dollar-circle-line stat-icon"></i>
            <p class="stat-value"><?= money($totalSales) ?></p>
            <p class="stat-label">Total Sales — <?= e($labelSuffix) ?></p>
        </div>
        <div class="stat-card border-info">
            <i class="ri-file-list-3-line stat-icon"></i>
            <p class="stat-value"><?= $totalCount ?></p>
            <p class="stat-label">Total Orders</p>
        </div>
        <div class="stat-card border-success">
            <i class="ri-funds-line stat-icon"></i>
            <p class="stat-value"><?= $totalCount > 0 ? money($totalSales / $totalCount) : money(0) ?></p>
            <p class="stat-label">Avg. Order Value</p>
        </div>
        <?php if ($totalRefunds > 0): ?>
        <div class="stat-card border-danger">
            <i class="ri-refund-line stat-icon"></i>
            <p class="stat-value text-red-600">−<?= money($totalRefunds) ?></p>
            <p class="stat-label">Refunds (<?= $refundCount ?>)</p>
        </div>
        <div class="stat-card border-accent">
            <i class="ri-scales-3-line stat-icon"></i>
            <p class="stat-value"><?= money($netSales) ?></p>
            <p class="stat-label">Net Sales (after refunds)</p>
        </div>
        <?php endif; ?>
        <?php if ((float)$taxRow['total_tax'] > 0): ?>
        <div class="stat-card border-warning">
            <i class="ri-percent-line stat-icon"></i>
            <p class="stat-value"><?= money($taxRow['total_tax']) ?></p>
            <p class="stat-label">Tax Collected (<?= getTaxRate() ?>%)</p>
        </div>
        <?php endif; ?>
        <?php if ($hasCostData): ?>
        <div class="stat-card border-danger">
            <i class="ri-shopping-basket-2-line stat-icon"></i>
            <p class="stat-value text-red-600">−<?= money($totalCogs) ?></p>
            <p class="stat-label">Cost of Goods Sold</p>
        </div>
        <div class="stat-card border-success">
            <i class="ri-line-chart-line stat-icon"></i>
            <p class="stat-value"><?= money($grossProfit) ?></p>
            <p class="stat-label">Gross Profit<?= $grossMarginPct !== null ? " ({$grossMarginPct}%)" : '' ?></p>
        </div>
        <?php endif; ?>
    </div>

    <!-- Tax breakdown callout -->
    <?php if ((float)$taxRow['total_tax'] > 0): ?>
    <div class="card mb-4 bg-blue-50/40 border border-blue-200">
        <div class="flex flex-wrap gap-6 text-sm">
            <div><span class="text-gray-500">Revenue (excl. tax)</span><br><strong class="text-lg"><?= money($taxRow['total_subtotal']) ?></strong></div>
            <div><span class="text-gray-500">Tax collected (<?= getTaxRate() ?>%)</span><br><strong class="text-lg text-blue-700"><?= money($taxRow['total_tax']) ?></strong></div>
            <div><span class="text-gray-500">Gross incl. tax</span><br><strong class="text-lg"><?= money((float)$taxRow['total_subtotal'] + (float)$taxRow['total_tax']) ?></strong></div>
        </div>
    </div>
    <?php endif; ?>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <!-- Sales by method -->
        <div class="card">
            <div class="flex items-center justify-between mb-3">
                <h3 class="font-semibold">Sales by Payment Method</h3>
                <a href="<?= exportUrl('sales', $period, $dateFrom, $dateTo) ?>" class="btn btn-outline btn-sm" title="Export CSV">
                    <i class="ri-download-line"></i> CSV
                </a>
            </div>
            <?php if (empty($byMethod)): ?>
            <p class="text-gray-500 text-sm">No data for this period.</p>
            <?php else: ?>
            <div class="space-y-3">
                <?php $maxTotal = max(array_column($byMethod, 'total')) ?: 1;
                foreach ($byMethod as $m):
                    $pct = round(($m['total'] / $maxTotal) * 100); ?>
                <div>
                    <div class="flex items-center justify-between mb-1">
                        <span class="capitalize text-sm font-medium"><?= e($m['method']) ?></span>
                        <div class="flex items-center gap-3">
                            <span class="text-xs text-gray-500"><?= $m['count'] ?> orders</span>
                            <span class="font-bold text-sm"><?= money($m['total']) ?></span>
                        </div>
                    </div>
                    <div class="w-full bg-gray-100 rounded-full h-2">
                        <div class="h-2 rounded-full bg-amber-500 transition-all" style="width:<?= $pct ?>%"></div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>

        <!-- Top items -->
        <div class="card">
            <div class="flex items-center justify-between mb-3">
                <h3 class="font-semibold">Top Selling Items</h3>
                <a href="<?= exportUrl('items', $period, $dateFrom, $dateTo) ?>" class="btn btn-outline btn-sm" title="Export CSV">
                    <i class="ri-download-line"></i> CSV
                </a>
            </div>
            <?php if (empty($topItems)): ?>
            <p class="text-gray-500 text-sm">No data for this period.</p>
            <?php else: ?>
            <div class="space-y-2">
                <?php foreach ($topItems as $i => $item): ?>
                <div class="flex items-center justify-between">
                    <span class="text-sm"><span class="text-gray-400 mr-2 font-mono"><?= $i + 1 ?>.</span><?= e($item['name']) ?></span>
                    <div class="flex items-center gap-3 flex-shrink-0">
                        <span class="text-xs text-gray-500">×<?= $item['qty'] ?></span>
                        <span class="font-bold text-sm"><?= money($item['total']) ?></span>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>
    </div>

    <!-- Profit margin by item (COGS) -->
    <div class="card mb-4">
        <div class="flex items-center justify-between mb-3">
            <h3 class="font-semibold"><i class="ri-scales-3-line text-amber-500 mr-1"></i> Profit Margin by Item</h3>
            <a href="<?= exportUrl('items', $period, $dateFrom, $dateTo) ?>" class="btn btn-outline btn-sm" title="Export CSV (includes cost/margin columns)">
                <i class="ri-download-line"></i> CSV
            </a>
        </div>
        <?php if (empty($cogsItems)): ?>
        <p class="text-gray-500 text-sm">No data for this period.</p>
        <?php else: ?>
        <?php if (!$hasCostData): ?>
        <p class="text-xs text-gray-400 mb-3">
            <i class="ri-information-line"></i> No items have complete cost data yet — link each menu item to its inventory
            (<a href="/bar/pages/inventory-mapping.php" class="underline">Menu → Inventory Mapping</a>) and set a unit cost on
            each stock item to see margins here.
        </p>
        <?php endif; ?>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Item</th><th class="text-right">Qty</th><th class="text-right">Revenue</th><th class="text-right">Cost</th><th class="text-right">Margin</th><th class="text-right">Margin %</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($cogsItems as $ci): ?>
                    <tr>
                        <td class="font-medium"><?= e($ci['name']) ?></td>
                        <td class="text-right"><?= (int)$ci['qty'] ?></td>
                        <td class="text-right"><?= money($ci['revenue']) ?></td>
                        <td class="text-right text-gray-500"><?= $ci['cost'] !== null ? money($ci['cost']) : '—' ?></td>
                        <td class="text-right font-medium <?= $ci['margin'] !== null && $ci['margin'] < 0 ? 'text-red-600' : '' ?>">
                            <?= $ci['margin'] !== null ? money($ci['margin']) : '—' ?>
                        </td>
                        <td class="text-right"><?= $ci['margin_pct'] !== null ? $ci['margin_pct'] . '%' : '—' ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php endif; ?>
    </div>

    <!-- Per-staff sales -->
    <div class="card">
        <div class="flex items-center justify-between mb-3">
            <h3 class="font-semibold"><i class="ri-user-star-line text-amber-500 mr-1"></i> Sales by Staff</h3>
            <a href="<?= exportUrl('staff', $period, $dateFrom, $dateTo) ?>" class="btn btn-outline btn-sm" title="Export CSV">
                <i class="ri-download-line"></i> CSV
            </a>
        </div>
        <?php if (empty($staffSales)): ?>
        <p class="text-gray-500 text-sm">No data for this period.</p>
        <?php else: ?>
        <?php $maxStaff = max(array_column($staffSales, 'total_sales')) ?: 1; ?>
        <div class="space-y-4">
            <?php foreach ($staffSales as $i => $s):
                $spct = round(($s['total_sales'] / $maxStaff) * 100);
                $medal = match($i) { 0 => '🥇', 1 => '🥈', 2 => '🥉', default => '' };
            ?>
            <div>
                <div class="flex items-center justify-between mb-1">
                    <span class="text-sm font-medium"><?= $medal ?> <?= e($s['staff_name'] ?? '(Unassigned)') ?></span>
                    <div class="flex items-center gap-4 text-sm">
                        <span class="text-gray-400"><?= $s['order_count'] ?> orders</span>
                        <span class="text-gray-400">avg <?= money($s['avg_order']) ?></span>
                        <span class="font-bold text-amber-700"><?= money($s['total_sales']) ?></span>
                    </div>
                </div>
                <div class="w-full bg-gray-100 rounded-full h-2">
                    <div class="h-2 rounded-full bg-amber-400 transition-all" style="width:<?= $spct ?>%"></div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </div>
</div>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
