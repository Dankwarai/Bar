<?php
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

if (isLoggedIn()) {
    header('Location: /bar/');
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $result = login($email, $password);
    if ($result['success']) {
        header('Location: /bar/');
        exit;
    }
    $error = $result['message'];
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In — <?= getSetting('bar_name', 'The Bar') ?></title>
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
                <i class="ri-bar-chart-2-fill text-white text-3xl"></i>
            </div>
            <h1 class="text-2xl font-bold text-white"><?= e(getSetting('bar_name', 'The Bar')) ?></h1>
            <p class="text-white/60 text-sm mt-1">Staff Login</p>
        </div>

        <form method="POST" class="login-card rounded-2xl shadow-2xl p-8 space-y-5">
            <?php if ($error): ?>
            <div class="bg-red-50 text-red-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2 border border-red-200">
                <i class="ri-close-circle-fill text-red-500"></i> <?= e($error) ?>
            </div>
            <?php endif; ?>
            <?php if (isset($_GET['timeout'])): ?>
            <div class="bg-amber-50 text-amber-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2 border border-amber-200">
                <i class="ri-time-line text-amber-500"></i> Session expired due to inactivity. Please log in again.
            </div>
            <?php endif; ?>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
                <div class="relative">
                    <i class="ri-mail-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    <input type="email" name="email" required class="form-input pl-10" placeholder="staff@bar.com">
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Password</label>
                <div class="relative">
                    <i class="ri-lock-line absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    <input type="password" name="password" required class="form-input pl-10" placeholder="••••••••">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-full py-2.5 text-base">
                <i class="ri-login-circle-line"></i> Sign In
            </button>
        </form>
    </div>
</body>
</html>
