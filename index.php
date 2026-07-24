<?php
require_once __DIR__ . '/includes/auth.php';
requireAuth();

// Route to dashboard
$page = $_GET['page'] ?? 'dashboard';

$allowedPages = [
    'dashboard'         => __DIR__ . '/pages/dashboard.php',
    'pos'               => __DIR__ . '/pages/pos.php',
    'menu'              => __DIR__ . '/pages/menu.php',
    'tables'            => __DIR__ . '/pages/tables.php',
    'qr-codes'          => __DIR__ . '/pages/qr-codes.php',
    'orders'            => __DIR__ . '/pages/orders.php',
    'inventory'         => __DIR__ . '/pages/inventory.php',
    'inventory-mapping' => __DIR__ . '/pages/inventory-mapping.php',
    'suppliers'         => __DIR__ . '/pages/suppliers.php',
    'staff'             => __DIR__ . '/pages/staff.php',
    'reports'           => __DIR__ . '/pages/reports.php',
    'reconciliation'    => __DIR__ . '/pages/reconciliation.php',
    'kitchen'           => __DIR__ . '/pages/kitchen.php',
    'audit-log'         => __DIR__ . '/pages/audit-log.php',
    'settings'          => __DIR__ . '/pages/settings.php',
];

$file = $allowedPages[$page] ?? __DIR__ . '/pages/dashboard.php';

require __DIR__ . '/includes/header.php';
require $file;
require __DIR__ . '/includes/footer.php';
