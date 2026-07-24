<?php
// Shared table CRUD actions — used by both pages/tables.php (manage view) and
// pages/qr-codes.php (print view), which are two different UIs over the same
// bar_tables data. Redirects back to whichever of the two pages included this file.
// Expects $action to already be set and CSRF already verified by the caller.

$selfPage = '/bar/pages/' . basename($_SERVER['SCRIPT_NAME']);

if ($action === 'add_table') {
    $stmt = db()->prepare("INSERT INTO `bar_tables` (number, capacity, qr_token) VALUES (?, ?, UUID())");
    $stmt->execute([(int)$_POST['number'], (int)$_POST['capacity']]);
    auditLog('table_add', "table #{$_POST['number']}", '');
    header("Location: {$selfPage}?msg=added");
    exit;
}

if ($action === 'edit_table' && $_POST['id']) {
    $id = (int)$_POST['id'];
    db()->prepare("UPDATE `bar_tables` SET number = ?, capacity = ? WHERE id = ?")
        ->execute([(int)$_POST['number'], (int)$_POST['capacity'], $id]);
    auditLog('table_edit', "table #{$_POST['number']}", "id:{$id}");
    header("Location: {$selfPage}?msg=edited");
    exit;
}

if ($action === 'toggle_table' && $_POST['id']) {
    $id = (int)$_POST['id'];
    db()->prepare("UPDATE `bar_tables` SET active = NOT active WHERE id = ?")->execute([$id]);
    $t = db()->prepare("SELECT number FROM bar_tables WHERE id = ?");
    $t->execute([$id]);
    $n = $t->fetchColumn();
    auditLog('table_toggle', "table #{$n}", "id:{$id}");
    header("Location: {$selfPage}");
    exit;
}

if ($action === 'toggle_reserved' && $_POST['id']) {
    $id = (int)$_POST['id'];
    $stmt = db()->prepare("SELECT number, status FROM bar_tables WHERE id = ?");
    $stmt->execute([$id]);
    $t = $stmt->fetch();
    // Only free <-> reserved is meaningful; leave an occupied table alone.
    if ($t && in_array($t['status'], ['free', 'reserved'], true)) {
        $newStatus = $t['status'] === 'reserved' ? 'free' : 'reserved';
        db()->prepare("UPDATE `bar_tables` SET status = ? WHERE id = ?")->execute([$newStatus, $id]);
        auditLog($newStatus === 'reserved' ? 'table_reserve' : 'table_unreserve', "table #{$t['number']}", "id:{$id}");
    }
    header("Location: {$selfPage}");
    exit;
}

if ($action === 'regenerate_token' && $_POST['id']) {
    $id = (int)$_POST['id'];
    db()->prepare("UPDATE `bar_tables` SET qr_token = UUID() WHERE id = ?")->execute([$id]);
    $t = db()->prepare("SELECT number FROM bar_tables WHERE id = ?");
    $t->execute([$id]);
    $n = $t->fetchColumn();
    auditLog('table_regenerate_qr', "table #{$n}", "id:{$id}");
    header("Location: {$selfPage}?msg=regenerated");
    exit;
}
