-- Bar Management System - Database Schema
-- Uses bar_ prefix within the existing school_db

USE school_db;

-- Roles
CREATE TABLE IF NOT EXISTS bar_roles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Users (Staff)
CREATE TABLE IF NOT EXISTS bar_users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT UNSIGNED NOT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES bar_roles(id)
) ENGINE=InnoDB;

-- Settings
CREATE TABLE IF NOT EXISTS bar_settings (
    `key` VARCHAR(100) PRIMARY KEY,
    `value` TEXT
) ENGINE=InnoDB;

-- Menu Categories
CREATE TABLE IF NOT EXISTS bar_categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- Menu Items
CREATE TABLE IF NOT EXISTS bar_menu_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255) DEFAULT NULL,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES bar_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tables
CREATE TABLE IF NOT EXISTS bar_tables (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number INT NOT NULL UNIQUE,
    capacity INT NOT NULL DEFAULT 2,
    status ENUM('free','occupied','reserved') NOT NULL DEFAULT 'free',
    qr_token VARCHAR(36) NOT NULL UNIQUE,
    active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- Orders
CREATE TABLE IF NOT EXISTS bar_orders (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED DEFAULT NULL,
    status ENUM('pending','accepted','ready','served','closed') NOT NULL DEFAULT 'pending',
    source ENUM('staff','customer') NOT NULL DEFAULT 'staff',
    customer_session VARCHAR(64) DEFAULT NULL,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    paid TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (table_id) REFERENCES bar_tables(id),
    FOREIGN KEY (user_id) REFERENCES bar_users(id)
) ENGINE=InnoDB;

-- Order Items
CREATE TABLE IF NOT EXISTS bar_order_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    menu_item_id INT UNSIGNED NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    status ENUM('ordered','preparing','ready','served','cancelled') NOT NULL DEFAULT 'ordered',
    FOREIGN KEY (order_id) REFERENCES bar_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES bar_menu_items(id)
) ENGINE=InnoDB;

-- Payments
CREATE TABLE IF NOT EXISTS bar_payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('cash','card','transfer','online') NOT NULL,
    reference VARCHAR(100) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES bar_orders(id)
) ENGINE=InnoDB;

-- Inventory Items
CREATE TABLE IF NOT EXISTS bar_inventory (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit VARCHAR(50) NOT NULL DEFAULT 'pcs',
    supplier_id INT UNSIGNED DEFAULT NULL,
    cost_price DECIMAL(10,2) DEFAULT NULL,
    low_stock_threshold DECIMAL(10,2) NOT NULL DEFAULT 10,
    FOREIGN KEY (supplier_id) REFERENCES bar_suppliers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Inventory Transactions
CREATE TABLE IF NOT EXISTS bar_inventory_transactions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT UNSIGNED NOT NULL,
    type ENUM('in','out','adjust') NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES bar_inventory(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============ SEED DATA ============

-- Roles
INSERT IGNORE INTO bar_roles (name) VALUES ('admin'), ('manager'), ('bartender'), ('server');

-- Default admin (password: admin123)
INSERT IGNORE INTO bar_users (name, email, password, role_id)
SELECT 'Admin', 'admin@bar.com', '$2y$10$OTYuhm/c4AWNbqFZjOQ/4uAeHI2GU7CGnz9WGBij5ZyC8mYKgeqXa', id FROM bar_roles WHERE name = 'admin'
LIMIT 1;

-- Default settings
INSERT IGNORE INTO bar_settings (`key`, `value`) VALUES
('bar_name', 'The Bar'),
('bar_address', '123 Main Street'),
('tax_rate', '10'),
('receipt_footer', 'Thank you for your patronage!'),
('qr_message', 'Scan. Order. Sip. Repeat.');

-- Sample categories
INSERT IGNORE INTO bar_categories (name, sort_order) VALUES
('Beers', 1), ('Cocktails', 2), ('Wines', 3), ('Spirits', 4), ('Soft Drinks', 5), ('Food & Snacks', 6);

-- Sample menu items
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Heineken Bottle', 'Premium lager beer 330ml', 3.50 FROM bar_categories bc WHERE bc.name = 'Beers' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Guinness Draught', 'Stout beer 330ml', 4.00 FROM bar_categories bc WHERE bc.name = 'Beers' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Star Lager', 'Classic lager beer 330ml', 2.50 FROM bar_categories bc WHERE bc.name = 'Beers' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Mojito', 'Mint, lime, rum, soda water', 6.00 FROM bar_categories bc WHERE bc.name = 'Cocktails' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Margarita', 'Tequila, lime, triple sec', 7.00 FROM bar_categories bc WHERE bc.name = 'Cocktails' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Pina Colada', 'Rum, coconut, pineapple', 6.50 FROM bar_categories bc WHERE bc.name = 'Cocktails' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Merlot (Glass)', 'Red wine glass', 5.00 FROM bar_categories bc WHERE bc.name = 'Wines' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Sauvignon Blanc (Glass)', 'White wine glass', 5.00 FROM bar_categories bc WHERE bc.name = 'Wines' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Johnnie Walker Black', 'Blended scotch whiskey 50ml', 8.00 FROM bar_categories bc WHERE bc.name = 'Spirits' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Jameson Irish Whiskey', 'Irish whiskey 50ml', 7.00 FROM bar_categories bc WHERE bc.name = 'Spirits' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Coca-Cola', 'Can 330ml', 1.50 FROM bar_categories bc WHERE bc.name = 'Soft Drinks' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Sprite', 'Can 330ml', 1.50 FROM bar_categories bc WHERE bc.name = 'Soft Drinks' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Chicken Wings (6pcs)', 'Buffalo wings with dip', 8.00 FROM bar_categories bc WHERE bc.name = 'Food & Snacks' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'French Fries', 'Crispy fries with ketchup', 4.00 FROM bar_categories bc WHERE bc.name = 'Food & Snacks' LIMIT 1;
INSERT IGNORE INTO bar_menu_items (category_id, name, description, price)
SELECT bc.id, 'Club Sandwich', 'Grilled chicken, bacon, lettuce, tomato', 7.00 FROM bar_categories bc WHERE bc.name = 'Food & Snacks' LIMIT 1;

-- Sample suppliers
INSERT IGNORE INTO bar_suppliers (name, contact_person, phone, email, address) VALUES
('Premium Beverages Ltd', 'John Okonkwo', '08031234567', 'john@premiumbeverages.ng', '12 Industrial Road, Lagos'),
('Global Drinks Distributors', 'Amanda Yusuf', '08079876543', 'amanda@globaldrinks.ng', '45 Trade Fair Complex, Abuja'),
('Fresh Farms Produce', 'Musa Ibrahim', '09051234567', 'musa@freshfarms.ng', '8 Farm Road, Ibadan'),
('Quick Supplies Co.', 'Chioma Obi', '08123456789', 'chioma@quicksupplies.ng', '22 Market Street, Enugu');

-- Sample tables
INSERT IGNORE INTO bar_tables (number, capacity, qr_token) VALUES
(1, 2, UUID()), (2, 2, UUID()), (3, 4, UUID()), (4, 4, UUID()),
(5, 6, UUID()), (6, 6, UUID()), (7, 8, UUID()), (8, 2, UUID()),
(9, 2, UUID()), (10, 4, UUID());

-- ============ ADDITIONS (added after initial schema) ============

-- Audit log
CREATE TABLE IF NOT EXISTS bar_audit_log (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id    INT UNSIGNED DEFAULT NULL,
    user_name  VARCHAR(100) NOT NULL DEFAULT '',
    action     VARCHAR(80)  NOT NULL,
    target     VARCHAR(200) NOT NULL DEFAULT '',
    details    TEXT,
    ip         VARCHAR(45)  NOT NULL DEFAULT '',
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_action     (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- Menu item → inventory item mapping (for auto-depletion)
CREATE TABLE IF NOT EXISTS bar_menu_inventory (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_item_id   INT UNSIGNED NOT NULL,
    inventory_id   INT UNSIGNED NOT NULL,
    qty_per_sale   DECIMAL(10,4) NOT NULL DEFAULT 1,  -- e.g. 0.33 for 330ml bottle from a keg
    UNIQUE KEY uq_menu_inv (menu_item_id, inventory_id),
    FOREIGN KEY (menu_item_id) REFERENCES bar_menu_items(id) ON DELETE CASCADE,
    FOREIGN KEY (inventory_id) REFERENCES bar_inventory(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Add tax columns to bar_orders if not present
ALTER TABLE bar_orders
    ADD COLUMN IF NOT EXISTS subtotal  DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER total,
    ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER subtotal;

-- Void tracking on orders
ALTER TABLE bar_orders
    ADD COLUMN IF NOT EXISTS voided      TINYINT(1)   NOT NULL DEFAULT 0 AFTER paid,
    ADD COLUMN IF NOT EXISTS void_reason VARCHAR(255) DEFAULT NULL        AFTER voided,
    ADD COLUMN IF NOT EXISTS voided_by   INT UNSIGNED DEFAULT NULL        AFTER void_reason;

-- Item-level notes/special requests
ALTER TABLE bar_order_items
    ADD COLUMN IF NOT EXISTS notes VARCHAR(255) DEFAULT NULL AFTER status;

-- Discount support on orders
ALTER TABLE bar_orders
    ADD COLUMN IF NOT EXISTS discount_type   ENUM('none','percent','fixed') NOT NULL DEFAULT 'none' AFTER tax_amount,
    ADD COLUMN IF NOT EXISTS discount_value  DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER discount_type,
    ADD COLUMN IF NOT EXISTS discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER discount_value;

-- Partial refunds
CREATE TABLE IF NOT EXISTS bar_refunds (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id     INT UNSIGNED NOT NULL,
    user_id      INT UNSIGNED NOT NULL,
    amount       DECIMAL(10,2) NOT NULL,
    reason       VARCHAR(255) NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    FOREIGN KEY (order_id) REFERENCES bar_orders(id),
    FOREIGN KEY (user_id)  REFERENCES bar_users(id)
) ENGINE=InnoDB;

-- How the refund was paid out — needed so cash reconciliation can tell cash
-- refunds (which reduce the physical drawer) from card/transfer/online ones.
-- NOTE: this server's MySQL (8.0.46) does not actually support "ADD COLUMN IF
-- NOT EXISTS" (confirmed by testing directly against it — it's a hard syntax
-- error, not a version-gated feature). This ALTER is written for a fresh
-- install where the column doesn't exist yet; on an install that already has
-- it, drop the "IF NOT EXISTS" or check first with:
--   SHOW COLUMNS FROM bar_refunds LIKE 'method';
ALTER TABLE bar_refunds
    ADD COLUMN method ENUM('cash','card','transfer','online') NOT NULL DEFAULT 'cash' AFTER amount;

-- Suppliers
CREATE TABLE IF NOT EXISTS bar_suppliers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(200) NOT NULL DEFAULT '',
    phone VARCHAR(50) NOT NULL DEFAULT '',
    email VARCHAR(100) NOT NULL DEFAULT '',
    address TEXT,
    notes TEXT,
    active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Restock events
CREATE TABLE IF NOT EXISTS bar_restocks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT UNSIGNED NOT NULL,
    supplier_id INT UNSIGNED DEFAULT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2) DEFAULT NULL,
    total_cost DECIMAL(10,2) DEFAULT NULL,
    note TEXT,
    received_by INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES bar_inventory(id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES bar_suppliers(id) ON DELETE SET NULL,
    FOREIGN KEY (received_by) REFERENCES bar_users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Payment reference must be unique so a retried Paystack webhook delivery, or a customer
-- reloading the receipt page mid-callback, can't record the same charge twice. NULL
-- references (cash/card/transfer taken at the till) are unaffected — MySQL treats every
-- NULL as distinct under a UNIQUE index, so staff payments are never compared against each other.
-- NOTE: if this fails with a duplicate-key error, first find and clean up existing dupes:
--   SELECT reference, COUNT(*) FROM bar_payments WHERE reference IS NOT NULL GROUP BY reference HAVING COUNT(*) > 1;
-- "IF NOT EXISTS" is omitted here too — see the note above on bar_refunds.method;
-- check first with SHOW INDEX FROM bar_payments WHERE Key_name = 'uq_bar_payments_reference'
-- if re-running this against an install that already has it.
ALTER TABLE bar_payments
    ADD UNIQUE INDEX uq_bar_payments_reference (reference);

-- Admin-generated password reset links for staff. The token itself is never
-- stored — only its SHA-256 hash — so a database leak can't be replayed into a
-- working reset link. The raw token only ever exists in the URL shown once to
-- the admin and in the link they hand the staff member.
ALTER TABLE bar_users
    ADD COLUMN reset_token VARCHAR(64) DEFAULT NULL,
    ADD COLUMN reset_token_expires DATETIME DEFAULT NULL;

-- Login rate limiting — every attempt (success or fail) is logged so login()
-- can look back over a time window and lock out an email or IP that's failing
-- repeatedly. Old rows are garbage-collected opportunistically from PHP; there's
-- no cron job in this app.
CREATE TABLE IF NOT EXISTS bar_login_attempts (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email      VARCHAR(100) NOT NULL,
    ip         VARCHAR(45)  NOT NULL,
    success    TINYINT(1)   NOT NULL DEFAULT 0,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email_created (email, created_at),
    INDEX idx_ip_created (ip, created_at)
) ENGINE=InnoDB;

-- Cash drawer reconciliation
CREATE TABLE IF NOT EXISTS bar_shift_reconciliation (
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
) ENGINE=InnoDB;
