<?php
// PHP defaults to UTC when no timezone is configured, but MySQL's NOW()/
// CURRENT_TIMESTAMP follow the server's system timezone. On this server
// that's West Africa Time (UTC+1) -- a mismatch that silently threw off
// every place the app compares PHP's time()/date() against a MySQL
// created_at value (most visibly: kitchen.php's order wait-time display
// showing negative minutes, which breaks its urgency color-coding).
// Nigeria doesn't observe DST, so this is a fixed, safe offset.
date_default_timezone_set('Africa/Lagos');

// Connection is lazy — only made on the first actual db() call, not merely
// when this file is required. Lets pure-logic code (and unit tests) pull in
// functions.php without forcing a live database connection to exist.
function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $config = require __DIR__ . '/../config/database.php';
        try {
            $dsn = "mysql:host={$config['host']};dbname={$config['dbname']};charset={$config['charset']}";
            $pdo = new PDO($dsn, $config['username'], $config['password'], [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
        } catch (PDOException $e) {
            die('Database connection failed: ' . $e->getMessage());
        }
    }
    return $pdo;
}
