# Bar Management System

## Overview
Full-stack bar management system with QR self-ordering, staff POS, inventory, and Paystack payment integration.

## Tech Stack
- **Frontend**: HTML, Tailwind CSS (CDN), Vanilla JS
- **Backend**: PHP 8+ (procedural)
- **Database**: MySQL
- **Auth**: Session-based login with role-based access
- **Payments**: Paystack (card payments on customer phone)
- **QR**: Client-side `qrcode.js` — no server dependency
- **Receipts**: CSS print styles for 80mm thermal paper

## User Roles

| Role | Access |
|------|--------|
| **admin** | Everything — users, settings, reports, menu, inventory |
| **manager** | Reports, inventory adjustments, menu management, all orders |
| **bartender** | POS order entry, view orders, update stock usage |
| **server** | POS order entry, table management, view own orders |

## Order Flow

### Staff Entry (POS)
```
Select table → Add items by category → Confirm order
→ Items sent to preparation → Mark ready → Serve
→ Payment at bar (cash/card/transfer) → Thermal receipt
```

### Customer Self-Order (QR)
```
Scan QR → Anonymous session (table token) → Browse menu
→ Add to cart (localStorage) → Submit order
→ Order appears on staff POS (pending status)
→ Staff accepts → Prepares → Serves
→ Customer pays on phone (Paystack) OR at bar
→ Receipt prints
```

## Database Tables

| Table | Purpose |
|-------|---------|
| `roles` | admin, manager, bartender, server |
| `users` | Staff accounts linked to roles |
| `categories` | Menu categories (beers, cocktails, food, etc.) |
| `menu_items` | Products with name, price, image, active status |
| `tables` | Dining tables with QR token, capacity, status |
| `orders` | Orders linked to table, staff, source (staff/customer) |
| `order_items` | Line items per order with status tracking |
| `payments` | Payment records with method, reference, amount |
| `settings` | Bar name, address, tax rate, receipt footer, QR message |
| `inventory` | Stock items with quantity and low-stock threshold |
| `inventory_transactions` | Stock movement log (in/out/adjust) |

## Project Structure

```
Bar/
├── index.php                 # Router — dispatches to pages
├── login.php                 # Staff login page
├── logout.php                # Logout handler
├── .env                      # DB credentials, Paystack keys
├── config/
│   └── database.php          # PDO connection
├── public/
│   ├── css/
│   │   ├── style.css         # Tailwind + custom styles
│   │   └── print.css         # 80mm thermal receipt styles
│   └── js/
│       ├── app.js            # Global app functions
│       ├── pos.js            # POS-specific logic
│       ├── qrcode.min.js     # QR code generation
│       └── customer.js       # Customer ordering logic
├── includes/
│   ├── auth.php              # Session/auth helpers
│   ├── db.php                # Database connection singleton
│   ├── header.php            # HTML head + nav sidebar
│   ├── footer.php            # Close tags + scripts
│   └── functions.php         # Utility functions
├── pages/
│   ├── dashboard.php
│   ├── pos.php
│   ├── menu.php
│   ├── tables.php
│   ├── qr-codes.php
│   ├── orders.php
│   ├── inventory.php
│   ├── staff.php
│   └── reports.php
├── customer/
│   ├── menu.php              # QR → menu listing
│   ├── order.php             # Order confirmation + pay
│   └── receipt.php           # Payment success receipt
├── webhook/
│   └── paystack.php          # Paystack payment callback
└── database/
    └── schema.sql            # Full database dump
```

## Pages & Routes

| Route | File | Auth | Roles |
|-------|------|------|-------|
| `/` | `index.php | dashboard.php` | Required | All |
| `/login` | `login.php` | Guest | — |
| `/logout` | `logout.php` | Required | All |
| `/pos` | `pages/pos.php` | Required | bartender, server, manager, admin |
| `/menu` | `pages/menu.php` | Required | admin, manager |
| `/tables` | `pages/tables.php` | Required | admin, manager |
| `/qr-codes` | `pages/qr-codes.php` | Required | admin, manager |
| `/orders` | `pages/orders.php` | Required | All |
| `/inventory` | `pages/inventory.php` | Required | admin, manager, bartender |
| `/staff` | `pages/staff.php` | Required | admin |
| `/reports` | `pages/reports.php` | Required | admin, manager |
| `/order/{token}` | `customer/menu.php` | Public (session) | — |
| `/order/{token}/confirm` | `customer/order.php` | Customer session | — |
| `/receipt/{ref}` | `customer/receipt.php` | Public | — |
| `/webhook/paystack` | `webhook/paystack.php` | Public (IP whitelist) | — |

## Payment Integration (Paystack)

### Customer Pays on Phone
1. After order accepted, customer sees "Pay Now" button
2. Click → Paystack popup with amount + order reference
3. Success → `payments` table updated, `orders.paid = 1`, `orders.status = closed`
4. Fail → customer can retry or pay at bar

### Paystack Checkout
- Public key for frontend popup
- Secret key for backend verification
- Webhook verifies `tx_ref` before updating order

## QR Print Page (A4)
- Sheet contains: Bar name, logo, custom quote message, grid of QR codes with table numbers
- Print-friendly CSS
- Message configurable in `settings` table (`qr_message` key)
