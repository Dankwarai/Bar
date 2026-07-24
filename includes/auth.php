<?php
require_once __DIR__ . '/db.php';

// ── Secure session configuration — must be set before session_start() ─────────
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_samesite', 'Strict');
// 8-hour shift lifetime — bartender stays logged in through a full service
ini_set('session.gc_maxlifetime', 8 * 60 * 60);   // 8 hours in seconds
ini_set('session.cookie_lifetime', 8 * 60 * 60);
// Enable 'Secure' flag only when served over HTTPS
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
    ini_set('session.cookie_secure', '1');
}

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// ── Idle timeout: log out after 4 hours of inactivity ────────────────────────
if (isset($_SESSION['user_id'])) {
    $idleLimit = 4 * 60 * 60; // 4 hours
    if (isset($_SESSION['_last_activity']) && (time() - $_SESSION['_last_activity']) > $idleLimit) {
        session_unset();
        session_destroy();
        header('Location: /bar/login.php?timeout=1');
        exit;
    }
    $_SESSION['_last_activity'] = time();
}

function isLoggedIn(): bool {
    return isset($_SESSION['user_id']);
}

function requireAuth(): void {
    if (!isLoggedIn()) {
        header('Location: /bar/login.php');
        exit;
    }
}

function requireRole(string ...$roles): void {
    requireAuth();
    if (!in_array($_SESSION['role'], $roles)) {
        http_response_code(403);
        die('Access denied.');
    }
}

function hasRole(string $role): bool {
    return isLoggedIn() && $_SESSION['role'] === $role;
}

// ── Login rate limiting ────────────────────────────────────────────────────────
const LOGIN_MAX_ATTEMPTS_PER_EMAIL = 5;
const LOGIN_MAX_ATTEMPTS_PER_IP    = 20;
const LOGIN_LOCKOUT_WINDOW_MINUTES = 15;

/**
 * Failed-login counts for this email and this IP within the lockout window.
 * Checked before touching the password at all, so a locked-out account never
 * even reaches password_verify().
 */
function recentFailedLoginCounts(string $email, string $ip): array {
    $stmt = db()->prepare("
        SELECT
            SUM(CASE WHEN email = ? THEN 1 ELSE 0 END) AS by_email,
            SUM(CASE WHEN ip = ?    THEN 1 ELSE 0 END) AS by_ip
        FROM bar_login_attempts
        WHERE success = 0 AND created_at >= (NOW() - INTERVAL ? MINUTE)
    ");
    $stmt->execute([$email, $ip, LOGIN_LOCKOUT_WINDOW_MINUTES]);
    $row = $stmt->fetch();
    return [
        'by_email' => (int)($row['by_email'] ?? 0),
        'by_ip'    => (int)($row['by_ip'] ?? 0),
    ];
}

function recordLoginAttempt(string $email, string $ip, bool $success): void {
    db()->prepare("INSERT INTO bar_login_attempts (email, ip, success) VALUES (?, ?, ?)")
        ->execute([$email, $ip, $success ? 1 : 0]);

    // Opportunistic cleanup — there's no cron job in this app, so garbage-collect
    // old attempt rows occasionally instead of letting the table grow forever.
    if (mt_rand(1, 200) === 1) {
        try {
            db()->exec("DELETE FROM bar_login_attempts WHERE created_at < (NOW() - INTERVAL 1 DAY)");
        } catch (Throwable $e) { /* best-effort, never block a login over this */ }
    }
}

function login(string $email, string $password): array {
    $ip = $_SERVER['REMOTE_ADDR'] ?? '';

    $attempts = recentFailedLoginCounts($email, $ip);
    if ($attempts['by_email'] >= LOGIN_MAX_ATTEMPTS_PER_EMAIL) {
        return ['success' => false, 'message' => 'Too many failed attempts for this account. Please try again in a few minutes.'];
    }
    if ($attempts['by_ip'] >= LOGIN_MAX_ATTEMPTS_PER_IP) {
        return ['success' => false, 'message' => 'Too many failed attempts from this location. Please try again in a few minutes.'];
    }

    $stmt = db()->prepare("
        SELECT u.*, r.name AS role_name
        FROM bar_users u
        JOIN bar_roles r ON r.id = u.role_id
        WHERE u.email = ? AND u.active = 1
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password'])) {
        recordLoginAttempt($email, $ip, true);

        // Regenerate session ID on privilege escalation (login) to prevent fixation
        session_regenerate_id(true);

        $_SESSION['user_id']    = $user['id'];
        $_SESSION['user_name']  = $user['name'];
        $_SESSION['user_email'] = $user['email'];
        $_SESSION['role']       = $user['role_name'];
        $_SESSION['role_id']    = $user['role_id'];
        return ['success' => true];
    }

    recordLoginAttempt($email, $ip, false);
    return ['success' => false, 'message' => 'Invalid email or password.'];
}

function logout(): void {
    session_regenerate_id(true);
    session_destroy();
    header('Location: /bar/login.php');
    exit;
}
