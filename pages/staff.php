<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
requireAuth();
requireRole('admin');

$action = $_POST['action'] ?? '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') verifyCsrf();

if ($action === 'add_staff') {
    $name     = trim($_POST['name']);
    $email    = trim($_POST['email']);
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $roleId   = (int)$_POST['role_id'];
    try {
        $stmt = db()->prepare("INSERT INTO bar_users (name, email, password, role_id) VALUES (?, ?, ?, ?)");
        $stmt->execute([$name, $email, $password, $roleId]);
        header('Location: /bar/pages/staff.php?msg=added');
    } catch (PDOException $e) {
        $msgKey = str_contains($e->getMessage(), 'Duplicate entry') ? 'duplicate_email' : 'save_failed';
        header('Location: /bar/pages/staff.php?msg=' . $msgKey);
    }
    exit;
}

if ($action === 'edit_staff') {
    $id     = (int)$_POST['id'];
    $name   = trim($_POST['name']);
    $email  = trim($_POST['email']);
    $roleId = (int)$_POST['role_id'];

    try {
        if (!empty($_POST['password'])) {
            $hash = password_hash($_POST['password'], PASSWORD_DEFAULT);
            db()->prepare("UPDATE bar_users SET name=?, email=?, password=?, role_id=? WHERE id=?")
                 ->execute([$name, $email, $hash, $roleId, $id]);
        } else {
            db()->prepare("UPDATE bar_users SET name=?, email=?, role_id=? WHERE id=?")
                 ->execute([$name, $email, $roleId, $id]);
        }
        header('Location: /bar/pages/staff.php?msg=updated');
    } catch (PDOException $e) {
        $msgKey = str_contains($e->getMessage(), 'Duplicate entry') ? 'duplicate_email' : 'save_failed';
        header('Location: /bar/pages/staff.php?msg=' . $msgKey);
    }
    exit;
}

if ($action === 'toggle_staff' && $_POST['id']) {
    db()->prepare("UPDATE bar_users SET active = NOT active WHERE id = ?")->execute([(int)$_POST['id']]);
    header('Location: /bar/pages/staff.php');
    exit;
}

// ── Admin-generated password reset link ───────────────────────────────────────
// No email server is configured anywhere in this app, so self-service "forgot
// password" isn't practical yet. Instead: admin generates a one-time link and
// hands it to the staff member however they like (WhatsApp, in person, etc.).
// Only the token's hash is stored — the raw token exists only in this one-time
// flash message and the link itself.
if ($action === 'generate_reset_link' && $_POST['id']) {
    $id = (int)$_POST['id'];
    $rawToken    = bin2hex(random_bytes(32));
    $hashedToken = hash('sha256', $rawToken);
    $expires     = date('Y-m-d H:i:s', time() + 24 * 60 * 60); // 24-hour validity

    db()->prepare("UPDATE bar_users SET reset_token = ?, reset_token_expires = ? WHERE id = ?")
        ->execute([$hashedToken, $expires, $id]);

    $nameStmt = db()->prepare("SELECT name FROM bar_users WHERE id = ?");
    $nameStmt->execute([$id]);
    auditLog('staff_reset_link_generated', "user #{$id}", $nameStmt->fetchColumn() ?: '');

    $baseUrl = rtrim(getSetting('bar_url', (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . dirname(dirname($_SERVER['SCRIPT_NAME']))), '/');
    $_SESSION['flash_reset_link'] = $baseUrl . '/reset-password.php?token=' . $rawToken;
    header('Location: /bar/pages/staff.php?msg=reset_link');
    exit;
}

if (!defined('BAR_HEADER_LOADED')) { $_standalone = true; require __DIR__ . '/../includes/header.php'; } else { $_standalone = false; }

$bar_roles = db()->query("SELECT * FROM bar_roles ORDER BY id")->fetchAll();
$staff     = db()->query("SELECT u.*, r.name AS role_name FROM bar_users u JOIN bar_roles r ON r.id = u.role_id ORDER BY u.name")->fetchAll();
$msg       = $_GET['msg'] ?? '';

$flashResetLink = $_SESSION['flash_reset_link'] ?? null;
unset($_SESSION['flash_reset_link']);
?>
<div class="p-4 md:p-6">
    <div class="page-header">
        <h2 class="page-title"><i class="ri-user-settings-line text-amber-500 mr-1"></i> Staff Management</h2>
        <button onclick="toggleModal('addStaffModal')" class="btn btn-primary btn-sm"><i class="ri-add-line"></i> Add Staff</button>
    </div>

    <?php if ($msg === 'added'): ?>
    <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-checkbox-circle-fill text-green-500"></i> Staff member added successfully.
    </div>
    <?php elseif ($msg === 'updated'): ?>
    <div class="flex items-center gap-2 bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-information-fill text-blue-500"></i> Staff member updated successfully.
    </div>
    <?php elseif ($msg === 'duplicate_email'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> That email is already in use by another staff account.
    </div>
    <?php elseif ($msg === 'save_failed'): ?>
    <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <i class="ri-close-circle-fill text-red-500"></i> Could not save staff member. Please try again.
    </div>
    <?php elseif ($msg === 'reset_link' && $flashResetLink): ?>
    <div class="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded-xl mb-4 text-sm">
        <div class="flex items-center gap-2 mb-2">
            <i class="ri-key-2-line text-blue-500"></i>
            <strong>One-time reset link generated</strong> — valid for 24 hours. Copy and send it to the staff member; it won't be shown again.
        </div>
        <div class="flex items-center gap-2 bg-white border border-blue-200 rounded-lg px-3 py-2">
            <code class="text-xs font-mono flex-1 truncate"><?= e($flashResetLink) ?></code>
            <button type="button" onclick="copyResetLink(this)" data-link="<?= e($flashResetLink) ?>" class="btn btn-ghost btn-xs text-blue-600 flex-shrink-0">
                <i class="ri-file-copy-line"></i> Copy
            </button>
        </div>
    </div>
    <?php endif; ?>

    <div class="card p-0">
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Joined</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($staff as $s): ?>
                    <tr>
                        <td class="font-medium"><?= e($s['name']) ?></td>
                        <td class="text-gray-500"><?= e($s['email']) ?></td>
                        <td><span class="badge badge-accepted capitalize"><?= e($s['role_name']) ?></span></td>
                        <td><span class="badge <?= $s['active'] ? 'badge-ready' : 'badge-closed' ?>"><?= $s['active'] ? 'Active' : 'Inactive' ?></span></td>
                        <td class="text-xs text-gray-400"><?= date('M j, Y', strtotime($s['created_at'])) ?></td>
                        <td>
                            <div class="flex items-center gap-1">
                                <button
                                    onclick="openEditStaff(<?= htmlspecialchars(json_encode([
                                        'id'      => $s['id'],
                                        'name'    => $s['name'],
                                        'email'   => $s['email'],
                                        'role_id' => $s['role_id'],
                                    ]), ENT_QUOTES) ?>)"
                                    class="btn btn-ghost btn-sm text-blue-600">
                                    <i class="ri-edit-line"></i> Edit
                                </button>
                                <form method="POST" class="inline" onsubmit="return confirm('Generate a password reset link for <?= e(addslashes($s['name'])) ?>?\nAny previous unused link for them will stop working.')">
                                    <input type="hidden" name="action" value="generate_reset_link">
                                    <input type="hidden" name="id" value="<?= $s['id'] ?>">
                                    <?= csrfField() ?>
                                    <button type="submit" class="btn btn-ghost btn-sm text-purple-600">
                                        <i class="ri-key-2-line"></i> Reset Link
                                    </button>
                                </form>
                                <form method="POST" class="inline">
                                    <input type="hidden" name="action" value="toggle_staff">
                                    <input type="hidden" name="id" value="<?= $s['id'] ?>">
                                    <?= csrfField() ?>
                                    <button type="submit" class="btn btn-ghost btn-sm <?= $s['active'] ? 'text-red-500' : 'text-green-600' ?>">
                                        <?= $s['active'] ? '<i class="ri-forbid-line"></i> Disable' : '<i class="ri-check-line"></i> Enable' ?>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Staff Modal -->
<div id="addStaffModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-user-add-line mr-1"></i> Add Staff</h3>
            <button type="button" onclick="toggleModal('addStaffModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="add_staff">
            <?= csrfField() ?>
            <div class="space-y-3">
                <div>
                    <label class="form-label">Full Name</label>
                    <input type="text" name="name" placeholder="John Doe" class="form-input" required>
                </div>
                <div>
                    <label class="form-label">Email</label>
                    <input type="email" name="email" placeholder="staff@bar.com" class="form-input" required>
                </div>
                <div>
                    <label class="form-label">Password</label>
                    <input type="password" name="password" placeholder="••••••••" class="form-input" required minlength="6">
                </div>
                <div>
                    <label class="form-label">Role</label>
                    <select name="role_id" class="form-select" required>
                        <option value="">Select role…</option>
                        <?php foreach ($bar_roles as $r): ?>
                        <option value="<?= $r['id'] ?>"><?= e($r['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Add Staff</button>
                <button type="button" onclick="toggleModal('addStaffModal')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Staff Modal -->
<div id="editStaffModal" class="modal-overlay hidden">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title"><i class="ri-edit-line mr-1"></i> Edit Staff</h3>
            <button type="button" onclick="toggleModal('editStaffModal')" class="modal-close"><i class="ri-close-line"></i></button>
        </div>
        <form method="POST">
            <input type="hidden" name="action" value="edit_staff">
            <input type="hidden" name="id" id="editStaffId">
            <?= csrfField() ?>
            <div class="space-y-3">
                <div>
                    <label class="form-label">Full Name</label>
                    <input type="text" name="name" id="editStaffName" placeholder="John Doe" class="form-input" required>
                </div>
                <div>
                    <label class="form-label">Email</label>
                    <input type="email" name="email" id="editStaffEmail" placeholder="staff@bar.com" class="form-input" required>
                </div>
                <div>
                    <label class="form-label">New Password <span class="text-gray-400 font-normal">(leave blank to keep current)</span></label>
                    <input type="password" name="password" placeholder="••••••••" class="form-input" minlength="6">
                </div>
                <div>
                    <label class="form-label">Role</label>
                    <select name="role_id" id="editStaffRole" class="form-select" required>
                        <?php foreach ($bar_roles as $r): ?>
                        <option value="<?= $r['id'] ?>"><?= e($r['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary flex-1">Save Changes</button>
                <button type="button" onclick="toggleModal('editStaffModal')" class="btn btn-outline">Cancel</button>
            </div>
        </form>
    </div>
</div>

<script>
function openEditStaff(data) {
    document.getElementById('editStaffId').value    = data.id;
    document.getElementById('editStaffName').value  = data.name;
    document.getElementById('editStaffEmail').value = data.email;
    document.getElementById('editStaffRole').value  = data.role_id;
    toggleModal('editStaffModal');
}

function copyResetLink(btn) {
    var link = btn.dataset.link;
    navigator.clipboard.writeText(link).then(function() {
        var orig = btn.innerHTML;
        btn.innerHTML = '<i class="ri-check-line"></i> Copied!';
        setTimeout(function() { btn.innerHTML = orig; }, 2000);
    }).catch(function() {
        prompt('Copy this link:', link);
    });
}
</script>
<?php if (!empty($_standalone)) require __DIR__ . '/../includes/footer.php'; ?>
