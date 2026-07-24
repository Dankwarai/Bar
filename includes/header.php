<?php
define('BAR_HEADER_LOADED', true);
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/functions.php';
$lowStockCount = (int)db()->query("SELECT COUNT(*) FROM bar_inventory WHERE quantity <= low_stock_threshold")->fetchColumn();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e(getSetting('bar_name', 'The Bar')) ?> — Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/bar/public/css/style.css">
</head>
<body class="min-h-screen">
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <nav class="w-64 bg-[#1a1a2e] text-white flex-shrink-0 hidden md:flex flex-col">
            <div class="p-5 border-b border-white/10">
                <h1 class="text-lg font-bold flex items-center gap-2.5">
                    <span class="w-8 h-8 rounded-lg bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center text-white text-sm font-bold">
                        <i class="ri-bar-chart-2-fill"></i>
                    </span>
                    <?= e(getSetting('bar_name', 'The Bar')) ?>
                </h1>
            </div>
            <div class="flex-1 overflow-y-auto p-3 space-y-0.5">
                <div class="sidebar-section">Main</div>
                <a href="/bar/" class="sidebar-link <?= basename($_SERVER['SCRIPT_NAME']) === 'index.php' || str_contains($_SERVER['REQUEST_URI'], 'dashboard') ? 'active' : '' ?>">
                    <i class="ri-dashboard-line"></i> Dashboard
                </a>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender', 'server'])): ?>
                <div class="sidebar-section">Operations</div>
                <a href="/bar/pages/pos.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'pos') ? 'active' : '' ?>">
                    <i class="ri-shopping-cart-2-line"></i> POS
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender'])): ?>
                <a href="/bar/pages/kitchen.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'kitchen') ? 'active' : '' ?>">
                    <i class="ri-restaurant-2-line"></i> Kitchen
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <a href="/bar/pages/menu.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'menu') ? 'active' : '' ?>">
                    <i class="ri-restaurant-line"></i> Menu
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender'])): ?>
                <a href="/bar/pages/inventory.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'inventory') && !str_contains($_SERVER['REQUEST_URI'], 'mapping') ? 'active' : '' ?>">
                    <i class="ri-stock-line"></i> Inventory
                    <?php if ($lowStockCount > 0): ?>
                    <span class="ml-auto bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[20px] text-center"><?= $lowStockCount ?></span>
                    <?php endif; ?>
                </a>
                <?php endif; ?>

                <div class="sidebar-section">Management</div>
                <a href="/bar/pages/orders.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'orders') ? 'active' : '' ?>">
                    <i class="ri-file-list-3-line"></i> Orders
                </a>
                <a href="/bar/pages/tables.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'tables') && !str_contains($_SERVER['REQUEST_URI'], 'qr') ? 'active' : '' ?>">
                    <i class="ri-table-line"></i> Tables
                </a>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <a href="/bar/pages/suppliers.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'suppliers') ? 'active' : '' ?>">
                    <i class="ri-truck-line"></i> Suppliers
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <a href="/bar/pages/qr-codes.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'qr-codes') ? 'active' : '' ?>">
                    <i class="ri-qr-code-line"></i> QR Codes
                </a>
                <a href="/bar/pages/reports.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'reports') ? 'active' : '' ?>">
                    <i class="ri-bar-chart-line"></i> Reports
                </a>
                <a href="/bar/pages/reconciliation.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'reconciliation') ? 'active' : '' ?>">
                    <i class="ri-safe-line"></i> Reconciliation
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender'])): ?>
                <a href="/bar/pages/kitchen.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'kitchen') ? 'active' : '' ?>">
                    <i class="ri-fire-line"></i> Kitchen
                </a>
                <?php endif; ?>

                <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
                <a href="/bar/pages/inventory-mapping.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'inventory-mapping') ? 'active' : '' ?>">
                    <i class="ri-links-line"></i> Inv. Mapping
                </a>
                <?php endif; ?>
                <?php if (($_SESSION['role'] ?? '') === 'admin'): ?>
                <div class="sidebar-section">System</div>
                <a href="/bar/pages/staff.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'staff') ? 'active' : '' ?>">
                    <i class="ri-user-settings-line"></i> Staff
                </a>
                <a href="/bar/pages/audit-log.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'audit-log') ? 'active' : '' ?>">
                    <i class="ri-shield-check-line"></i> Audit Log
                </a>
                <a href="/bar/pages/settings.php" class="sidebar-link <?= str_contains($_SERVER['REQUEST_URI'], 'settings') ? 'active' : '' ?>">
                    <i class="ri-settings-3-line"></i> Settings
                </a>
                <?php endif; ?>
            </div>
            <div class="p-4 border-t border-white/10">
                <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-full bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center text-white text-sm font-bold">
                        <?= strtoupper(substr($_SESSION['user_name'] ?? 'U', 0, 1)) ?>
                    </div>
                    <div class="flex-1 min-w-0">
                        <div class="text-sm font-medium truncate"><?= e($_SESSION['user_name'] ?? '') ?></div>
                        <div class="text-xs text-white/50 capitalize"><?= e($_SESSION['role'] ?? '') ?></div>
                    </div>
                    <a href="/bar/logout.php" class="text-white/40 hover:text-red-400 transition" title="Logout">
                        <i class="ri-logout-box-line"></i>
                    </a>
                </div>
            </div>
        </nav>

        <!-- Mobile header -->
        <div class="md:hidden fixed top-0 left-0 right-0 bg-[#1a1a2e] text-white z-50 px-4 py-3 flex items-center justify-between shadow-lg">
            <button onclick="document.getElementById('mobileNav').classList.toggle('hidden')" class="text-xl p-1">
                <i class="ri-menu-line"></i>
            </button>
            <div class="flex items-center gap-2">
                <span class="w-6 h-6 rounded bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center text-xs font-bold">
                    <i class="ri-bar-chart-2-fill"></i>
                </span>
                <h1 class="font-bold text-sm"><?= e(getSetting('bar_name', 'The Bar')) ?></h1>
            </div>
            <a href="/bar/logout.php" class="text-white/50"><i class="ri-logout-box-line text-lg"></i></a>
        </div>
        <div id="mobileNav" class="md:hidden fixed top-14 left-0 right-0 bg-[#1a1a2e] text-white z-50 hidden p-4 space-y-1 text-sm shadow-xl">
            <div class="sidebar-section">Main</div>
            <a href="/bar/" class="sidebar-link">Dashboard</a>
            <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender', 'server'])): ?>
            <div class="sidebar-section">Operations</div>
            <a href="/bar/pages/pos.php" class="sidebar-link">POS</a>
            <?php endif; ?>
            <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender'])): ?>
            <a href="/bar/pages/kitchen.php" class="sidebar-link">Kitchen</a>
            <?php endif; ?>
            <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager', 'bartender'])): ?>
            <a href="/bar/pages/menu.php" class="sidebar-link">Menu</a>
            <a href="/bar/pages/inventory.php" class="sidebar-link">Inventory
                <?php if ($lowStockCount > 0): ?>
                <span class="ml-auto bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full"><?= $lowStockCount ?></span>
                <?php endif; ?>
            </a>
            <?php endif; ?>
            <div class="sidebar-section">Management</div>
            <a href="/bar/pages/orders.php" class="sidebar-link">Orders</a>
            <a href="/bar/pages/tables.php" class="sidebar-link">Tables</a>
            <?php if (in_array($_SESSION['role'] ?? '', ['admin', 'manager'])): ?>
            <a href="/bar/pages/suppliers.php" class="sidebar-link">Suppliers</a>
            <a href="/bar/pages/inventory-mapping.php" class="sidebar-link">Inv. Mapping</a>
            <a href="/bar/pages/qr-codes.php" class="sidebar-link">QR Codes</a>
            <a href="/bar/pages/reports.php" class="sidebar-link">Reports</a>
            <a href="/bar/pages/reconciliation.php" class="sidebar-link">Reconciliation</a>
            <?php endif; ?>
            <?php if (($_SESSION['role'] ?? '') === 'admin'): ?>
            <div class="sidebar-section">System</div>
            <a href="/bar/pages/staff.php" class="sidebar-link">Staff</a>
            <a href="/bar/pages/audit-log.php" class="sidebar-link">Audit Log</a>
            <a href="/bar/pages/settings.php" class="sidebar-link">Settings</a>
            <?php endif; ?>
        </div>

        <!-- Main content -->
        <main class="flex-1 overflow-y-auto md:pt-0 pt-16 page-fade-in">
