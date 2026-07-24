<?php
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

$token       = trim($_GET['token'] ?? $_POST['token'] ?? '');
$hashedToken = $token !== '' ? hash('sha256', $token) : '';

$user = null;
if ($hashedToken !== '') {
    $stmt = db()->prepare("SELECT id, name FROM bar_users WHERE reset_token = ? AND reset_token_expires > NOW() AND active = 1");
    $stmt->execute([$hashedToken]);
    $user = $stmt->fetch();
}

$error   = '';
$success = false;

if ($user && $_SERVER['REQUEST_METHOD'] === 'POST') {
    verifyCsrf();
    $password = $_POST['password'] ?? '';
    $confirm  = $_POST['password_confirm'] ?? '';

    if (strlen($password) < 6) {
        $error = 'Password must be at least 6 characters.';
    } elseif ($password !== $confirm) {
        $error = 'Passwords do not match.';
    } else {
        $hash = password_hash($password, PASSWORD_DEFAULT);
        db()->prepare("UPDATE bar_users SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE id = ?")
            ->execute([$hash, $user['id']]);
        auditLog('staff_password_reset', "user #{$user['id']}", 'reset via one-time link');
        $success = true;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password — <?= e(getSetting('bar_name', 'The Bar')) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/bar/public/css/style.css">
    <style>
        body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        .login-bg { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); }
        .login-card { backdrop-filter: blur(20px); background: rgba(255,255,255,0.95); }
    </style>
</head>
<body class="min-h-screen login-bg flex items-center justify-center p-4">
    <div class="w-full max-w-sm">
        <div class="text-center mb-8">
            <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center mx-auto mb-4 shadow-lg">
                <i class="ri-key-2-fill text-white text-3xl"></i>
            </div>
            <h1 class="text-2xl font-bold text-white"><?= e(getSetting('bar_name', 'The Bar')) ?></h1>
            <p class="text-white/60 text-sm mt-1">Reset Password</p>
        </div>

        <?php if (!$user): ?>
        <div class="login-card rounded-2xl shadow-2xl p-8 text-center">
            <div class="w-14 h-14 rounded-full bg-red-100 flex items-center justify-center mx-auto mb-4">
                <i class="ri-close-line text-red-600 text-2xl"></i>
            </div>
            <h2 class="font-bold text-lg mb-2">Link invalid or expired</h2>
            <p class="text-sm text-gray-500 mb-4">This reset link is no longer valid — it may have already been used, expired (24-hour limit), or the account may be disabled. Ask your admin to generate a new one.</p>
            <a href="/bar/login.php" class="btn btn-outline inline-block">Back to Login</a>
        </div>
        <?php elseif ($success): ?>
        <div class="login-card rounded-2xl shadow-2xl p-8 text-center">
            <div class="w-14 h-14 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-4">
                <i class="ri-check-line text-green-600 text-2xl"></i>
            </div>
            <h2 class="font-bold text-lg mb-2">Password updated</h2>
            <p class="text-sm text-gray-500 mb-4">Your password has been changed. You can log in now.</p>
            <a href="/bar/login.php" class="btn btn-primary inline-block">Go to Login</a>
        </div>
        <?php else: ?>
        <form method="POST" class="login-card rounded-2xl shadow-2xl p-8 space-y-5">
            <input type="hidden" name="token" value="<?= e($token) ?>">
            <?= csrfField() ?>
            <p class="text-sm text-gray-500 -mt-1">Hi <?= e($user['name']) ?> — set a new password below.</p>

            <?php if ($error): ?>
            <div class="bg-red-50 text-red-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2 border border-red-200">
                <i class="ri-close-circle-fill text-red-500"></i> <?= e($error) ?>
            </div>
            <?php endif; ?>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">New Password</label>
                <div class="relative">
                    <i class="ri-lock-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    <input type="password" name="password" required minlength="6" class="form-input pl-10" placeholder="••••••••">
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Confirm New Password</label>
                <div class="relative">
                    <i class="ri-lock-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    <input type="password" name="password_confirm" required minlength="6" class="form-input pl-10" placeholder="••••••••">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-full py-2.5 text-base">
                <i class="ri-check-line"></i> Set New Password
            </button>
        </form>
        <?php endif; ?>
    </div>
</body>
</html>
