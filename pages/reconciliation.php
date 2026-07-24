<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin', 'manager');

$action = $_POST['action'] ?? '';

// Ensure the table exists (graceful degradation)
try {
    db()->query("CREATE TABLE IF NOT EXISTS bar_shift_reconciliation (
        id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id          INT UNSIGNED NOT NULL,
        shift_date       DATE NOT NULL,
        opened_at        DATETIME DEFAULT NULL,
        closed_at        DATETIME DEFAULT NULL,
        opening_float    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        expected_cash    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        actual_cash      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        total_card       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        total_transfer   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        total_online     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        total_sales      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        total_refunds    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        notes            TEXT,
        status           ENUM('open','closed') NOT NULL DEFAULT 'open',
        INDEX idx_shift_date (shift_date),
        FOREIGN KEY (user_id) REFERENCES bar_users(id)
    ) ENGINE=InnoDB");
} catch (Throwable $e) { /* table already exists */ }
// Table may already exist from before total_refunds was added — patch it in.
// "ADD COLUMN IF NOT EXISTS" isn't actually supported on this MySQL version
// (confirmed directly against it — it's a syntax error, not just a no-op), so
// the existence check has to be done manually first.
try {
    $hasColumn = db()->query("SHOW COLUMNS FROM bar_shift_reconciliation LIKE 'total_refunds'")->fetch();
    if (!$hasColumn) {
        db()->exec("ALTER TABLE bar_shift_reconciliation ADD COLUMN total_refunds DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER total_sales");
    }
} catch (Throwable $e) { /* best-effort self-heal; ignore if it fails */ }

// ── Open shift ────────────────────────────────────────────────────────────────
if ($action === 'open_shift') {
    verifyCsrf();
    $float = (float)str_replace(',', '', $_POST['opening_float'] ?? '0');

    // Check no open shift today for this user
    $exists = db()->prepare("SELECT id FROM bar_shift_reconciliation WHERE user_id = ? AND shift_date = CURDATE() AND status = 'open'");
    $exists->execute([$_SESSION['user_id']]);
    if (!$exists->fetch()) {
        db()->prepare("INSERT INTO bar_shift_reconciliation (user_id, shift_date, opened_at, opening_float, status) VALUES (?, CURDATE(), NOW(), ?, 'open')")
            ->execute([$_SESSION['user_id'], $float]);
        auditLog('shift_open', 'shift', "float: {$float}");
    }
    header('Location: /bar/pages/reconciliation.php');
    exit;
}

// ── Close shift ───────────────────────────────────────────────────────────────
if ($action === 'close_shift') {
    verifyCsrf();
    $shiftId    = (int)$_POST['shift_id'];
    $actualCash = (float)str_replace(',', '', $_POST['actual_cash'] ?? '0');
    $notes      = trim($_POST['notes'] ?? '');

    // Fetch shift to get open time
    $shift = db()->prepare("SELECT * FROM bar_shift_reconciliation WHERE id = ? AND user_id = ? AND status = 'open'");
    $shift->execute([$shiftId, $_SESSION['user_id']]);
    $shiftRow = $shift->fetch();
    if (!$shiftRow) die('Shift not found or already closed.');

    // Sum payments since shift opened
    $since = $shiftRow['opened_at'];
    $totals = db()->prepare("
        SELECT
            COALESCE(SUM(CASE WHEN method = 'cash'     THEN amount ELSE 0 END), 0) AS cash,
            COALESCE(SUM(CASE WHEN method = 'card'     THEN amount ELSE 0 END), 0) AS card,
            COALESCE(SUM(CASE WHEN method = 'transfer' THEN amount ELSE 0 END), 0) AS transfer,
            COALESCE(SUM(CASE WHEN method = 'online'   THEN amount ELSE 0 END), 0) AS online,
            COALESCE(SUM(amount), 0) AS total
        FROM bar_payments
        WHERE created_at >= ?
    ");
    $totals->execute([$since]);
    $t = $totals->fetch();

    // Refunds since shift opened — cash refunds come straight out of the drawer,
    // and any refund (regardless of method) reduces net sales for the shift.
    $refunds = db()->prepare("
        SELECT
            COALESCE(SUM(CASE WHEN method = 'cash'     THEN amount ELSE 0 END), 0) AS cash,
            COALESCE(SUM(CASE WHEN method = 'card'     THEN amount ELSE 0 END), 0) AS card,
            COALESCE(SUM(CASE WHEN method = 'transfer' THEN amount ELSE 0 END), 0) AS transfer,
            COALESCE(SUM(CASE WHEN method = 'online'   THEN amount ELSE 0 END), 0) AS online,
            COALESCE(SUM(amount), 0) AS total
        FROM bar_refunds
        WHERE created_at >= ?
    ");
    $refunds->execute([$since]);
    $r = $refunds->fetch();

    $expectedCash = (float)$shiftRow['opening_float'] + (float)$t['cash'] - (float)$r['cash'];
    $netCard      = (float)$t['card']     - (float)$r['card'];
    $netTransfer  = (float)$t['transfer'] - (float)$r['transfer'];
    $netOnline    = (float)$t['online']   - (float)$r['online'];
    $netSales     = (float)$t['total']    - (float)$r['total'];

    db()->prepare("
        UPDATE bar_shift_reconciliation
        SET closed_at = NOW(), actual_cash = ?, expected_cash = ?,
            total_card = ?, total_transfer = ?, total_online = ?,
            total_sales = ?, total_refunds = ?, notes = ?, status = 'closed'
        WHERE id = ?
    ")->execute([
        $actualCash, $expectedCash,
        $netCard, $netTransfer, $netOnline,
        $netSales, $r['total'], $notes, $shiftId,
    ]);

    $over = round($actualCash - $expectedCash, 2);
    auditLog('shift_close', "shift #{$shiftId}", sprintf('expected:%.2f actual:%.2f over/short:%.2f refunds:%.2f', $expectedCash, $actualCash, $over, $r['total']));
    header('Location: /bar/pages/reconciliation.php?closed=' . $shiftId);
    exit;
}

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

// ── Page data ─────────────────────────────────────────────────────────────────
// Open shift for current user today
$openShift = db()->prepare("SELECT * FROM bar_shift_reconciliation WHERE user_id = ? AND shift_date = CURDATE() AND status = 'open' LIMIT 1");
$openShift->execute([$_SESSION['user_id']]);
$openShift = $openShift->fetch();

// Live totals since shift opened (for display)
$liveTotals = null;
$liveRefunds = null;
if ($openShift) {
    $lt = db()->prepare("
        SELECT
            COALESCE(SUM(CASE WHEN method = 'cash'     THEN amount ELSE 0 END), 0) AS cash,
            COALESCE(SUM(CASE WHEN method = 'card'     THEN amount ELSE 0 END), 0) AS card,
            COALESCE(SUM(CASE WHEN method = 'transfer' THEN amount ELSE 0 END), 0) AS transfer,
            COALESCE(SUM(CASE WHEN method = 'online'   THEN amount ELSE 0 END), 0) AS online,
            COALESCE(SUM(amount), 0) AS total,
            COUNT(*) AS txn_count
        FROM bar_payments
        WHERE created_at >= ?
    ");
    $lt->execute([$openShift['opened_at']]);
    $liveTotals = $lt->fetch();

    $lr = db()->prepare("
        SELECT
            COALESCE(SUM(CASE WHEN method = 'cash' THEN amount ELSE 0 END), 0) AS cash,
            COALESCE(SUM(amount), 0) AS total,
            COUNT(*) AS txn_count
        FROM bar_refunds
        WHERE created_at >= ?
    ");
    $lr->execute([$openShift['opened_at']]);
    $liveRefunds = $lr->fetch();
}

// Past 10 shifts
$history = db()->prepare("
    SELECT r.*, u.name AS user_name
    FROM bar_shift_reconciliation r
    JOIN bar_users u ON u.id = r.user_id
    ORDER BY r.shift_date DESC, r.id DESC
    LIMIT 20
");
$history->execute();
$history = $history->fetchAll();

$closedId = (int)($_GET['closed'] ?? 0);
$closedShift = null;
if ($closedId) {
    $cs = db()->prepare("SELECT * FROM bar_shift_reconciliation WHERE id = ?");
    $cs->execute([$closedId]);
    $closedShift = $cs->fetch();
}
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-safe-line text-amber-500 mr-1"></i> Cash Reconciliation</h2>
    </div>

    <?php if ($closedShift): ?>
    <?php $over = round((float)$closedShift['actual_cash'] - (float)$closedShift['expected_cash'], 2); ?>
    <div class="card mb-6 border-l-4 <?= $over >= 0 ? 'border-green-500 bg-green-50/40' : 'border-red-500 bg-red-50/40' ?>">
        <h3 class="font-bold text-lg mb-4"><i class="ri-flag-line mr-1"></i> Shift #<?= $closedShift['id'] ?> Closed</h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
            <div><p class="text-xs text-gray-500">Net Sales<?= (float)($closedShift['total_refunds'] ?? 0) > 0 ? ' (after refunds)' : '' ?></p><p class="text-xl font-bold"><?= money($closedShift['total_sales']) ?></p></div>
            <div><p class="text-xs text-gray-500">Expected Cash</p><p class="text-xl font-bold"><?= money($closedShift['expected_cash']) ?></p></div>
            <div><p class="text-xs text-gray-500">Actual Cash</p><p class="text-xl font-bold"><?= money($closedShift['actual_cash']) ?></p></div>
            <div>
                <p class="text-xs text-gray-500">Over / Short</p>
                <p class="text-xl font-bold <?= $over >= 0 ? 'text-green-600' : 'text-red-600' ?>">
                    <?= ($over >= 0 ? '+' : '') . money($over) ?>
                </p>
            </div>
        </div>
        <div class="grid grid-cols-3 md:grid-cols-4 gap-4 text-center mt-4 pt-4 border-t text-sm">
            <div><p class="text-xs text-gray-500">Card</p><p class="font-semibold"><?= money($closedShift['total_card']) ?></p></div>
            <div><p class="text-xs text-gray-500">Transfer</p><p class="font-semibold"><?= money($closedShift['total_transfer']) ?></p></div>
            <div><p class="text-xs text-gray-500">Online</p><p class="font-semibold"><?= money($closedShift['total_online']) ?></p></div>
            <?php if ((float)($closedShift['total_refunds'] ?? 0) > 0): ?>
            <div><p class="text-xs text-gray-500">Refunds</p><p class="font-semibold text-red-600">−<?= money($closedShift['total_refunds']) ?></p></div>
            <?php endif; ?>
        </div>
        <?php if ($closedShift['notes']): ?>
        <p class="text-sm text-gray-600 mt-3 italic">"<?= e($closedShift['notes']) ?>"</p>
        <?php endif; ?>
        <a href="/bar/pages/reconciliation.php" class="btn btn-outline btn-sm mt-4">View All Shifts</a>
    </div>
    <?php endif; ?>

    <?php if ($openShift): ?>
    <!-- Active shift panel -->
    <div class="card mb-6 border-l-4 border-amber-400">
        <div class="flex items-center justify-between mb-4">
            <div>
                <h3 class="font-bold text-base"><i class="ri-time-line text-amber-500 mr-1"></i> Shift Open</h3>
                <p class="text-xs text-gray-400">Started <?= date('H:i', strtotime($openShift['opened_at'])) ?> &bull; Float: <?= money($openShift['opening_float']) ?></p>
            </div>
            <span class="badge bg-green-100 text-green-700 border border-green-200">Live</span>
        </div>

        <?php if ($liveTotals): ?>
        <div class="grid grid-cols-2 md:grid-cols-5 gap-3 mb-5">
            <div class="card bg-gray-50 text-center p-3">
                <p class="text-xs text-gray-500">Cash</p>
                <p class="text-lg font-bold text-green-700"><?= money($liveTotals['cash']) ?></p>
            </div>
            <div class="card bg-gray-50 text-center p-3">
                <p class="text-xs text-gray-500">Card</p>
                <p class="text-lg font-bold"><?= money($liveTotals['card']) ?></p>
            </div>
            <div class="card bg-gray-50 text-center p-3">
                <p class="text-xs text-gray-500">Transfer</p>
                <p class="text-lg font-bold"><?= money($liveTotals['transfer']) ?></p>
            </div>
            <div class="card bg-gray-50 text-center p-3">
                <p class="text-xs text-gray-500">Online</p>
                <p class="text-lg font-bold"><?= money($liveTotals['online']) ?></p>
            </div>
            <div class="card bg-amber-50 text-center p-3">
                <p class="text-xs text-gray-500">Total (<?= $liveTotals['txn_count'] ?> txns)</p>
                <p class="text-lg font-bold text-amber-700"><?= money($liveTotals['total']) ?></p>
            </div>
        </div>
        <?php if ($liveRefunds && (float)$liveRefunds['total'] > 0): ?>
        <div class="flex items-center gap-3 bg-red-50 border border-red-200 text-red-700 px-4 py-2.5 rounded-xl text-sm mb-3">
            <i class="ri-refund-line flex-shrink-0"></i>
            <span class="flex-1">Refunds this shift (<?= $liveRefunds['txn_count'] ?>)</span>
            <span class="font-bold">−<?= money($liveRefunds['total']) ?></span>
        </div>
        <?php endif; ?>
        <p class="text-xs text-gray-400 mb-4">
            Expected cash in drawer: <strong><?= money((float)$openShift['opening_float'] + (float)$liveTotals['cash'] - (float)($liveRefunds['cash'] ?? 0)) ?></strong>
            (float + cash sales<?= (float)($liveRefunds['cash'] ?? 0) > 0 ? ' − cash refunds' : '' ?>)
        </p>
        <?php endif; ?>

        <!-- Close shift form -->
        <form method="POST" class="space-y-3 border-t pt-4">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="close_shift">
            <input type="hidden" name="shift_id" value="<?= $openShift['id'] ?>">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div>
                    <label class="form-label">Actual Cash in Drawer <span class="text-red-500">*</span></label>
                    <input type="number" step="0.01" min="0" name="actual_cash" class="form-input" placeholder="0.00" required>
                    <p class="text-xs text-gray-400 mt-1">Count the physical cash and enter the total.</p>
                </div>
                <div>
                    <label class="form-label">Notes <span class="text-gray-400 font-normal">(optional)</span></label>
                    <input type="text" name="notes" class="form-input" placeholder="e.g. Petty cash used for ice">
                </div>
            </div>
            <button type="submit" class="btn btn-danger" onclick="return confirm('Close this shift? This cannot be undone.')">
                <i class="ri-flag-line"></i> Close Shift & Generate Report
            </button>
        </form>
    </div>

    <?php else: ?>
    <!-- Open new shift form -->
    <div class="card mb-6">
        <h3 class="font-semibold mb-3"><i class="ri-play-circle-line text-green-500 mr-1"></i> Open Today's Shift</h3>
        <p class="text-sm text-gray-500 mb-4">Enter the opening float (cash in the drawer at shift start). You'll close the shift at end of service to reconcile.</p>
        <form method="POST" class="flex flex-wrap gap-3 items-end">
            <?= csrfField() ?>
            <input type="hidden" name="action" value="open_shift">
            <div class="flex-1 min-w-[200px]">
                <label class="form-label">Opening Float (₦)</label>
                <input type="number" step="0.01" min="0" name="opening_float" class="form-input" placeholder="0.00" value="0">
            </div>
            <button type="submit" class="btn btn-primary"><i class="ri-play-line"></i> Open Shift</button>
        </form>
    </div>
    <?php endif; ?>

    <!-- Shift history -->
    <?php if ($history): ?>
    <div class="card">
        <h3 class="font-semibold mb-4">Recent Shifts</h3>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Date</th><th>Staff</th><th>Float</th><th>Net Sales</th><th>Refunds</th><th>Expected Cash</th><th>Actual Cash</th><th>Over/Short</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($history as $row):
                        $over = round((float)$row['actual_cash'] - (float)$row['expected_cash'], 2);
                        $overColor = $row['status'] === 'closed' ? ($over >= 0 ? 'text-green-600' : 'text-red-600') : 'text-gray-400';
                    ?>
                    <tr>
                        <td><?= date('D d M', strtotime($row['shift_date'])) ?></td>
                        <td><?= e($row['user_name']) ?></td>
                        <td><?= money($row['opening_float']) ?></td>
                        <td class="font-semibold"><?= money($row['total_sales']) ?></td>
                        <td class="text-red-600"><?= (float)($row['total_refunds'] ?? 0) > 0 ? '−' . money($row['total_refunds']) : '—' ?></td>
                        <td><?= money($row['expected_cash']) ?></td>
                        <td><?= money($row['actual_cash']) ?></td>
                        <td class="font-bold <?= $overColor ?>">
                            <?= $row['status'] === 'closed' ? ($over >= 0 ? '+' : '') . money($over) : '—' ?>
                        </td>
                        <td>
                            <span class="badge <?= $row['status'] === 'open' ? 'bg-green-100 text-green-700 border-green-200' : 'bg-gray-100 text-gray-600 border-gray-200' ?> border">
                                <?= $row['status'] ?>
                            </span>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
    <?php endif; ?>
</div>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
