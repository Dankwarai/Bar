<?php
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/functions.php';

$token = $_GET['token'] ?? '';
if (!$token) die('Invalid QR code.');

$stmt = db()->prepare("SELECT id, number, status FROM `bar_tables` WHERE qr_token = ? AND active = 1");
$stmt->execute([$token]);
$table = $stmt->fetch();

if (!$table) die('Table not found.');

// Start customer session
if (session_status() === PHP_SESSION_NONE) session_start();
$customerSession = $_SESSION['customer_session'] ?? bin2hex(random_bytes(16));
$_SESSION['customer_session'] = $customerSession;
$_SESSION['table_id'] = $table['id'];
$_SESSION['table_number'] = $table['number'];
$_SESSION['table_token'] = $token;

$categories = db()->query("SELECT * FROM bar_categories ORDER BY sort_order")->fetchAll();
$items = db()->query("SELECT mi.*, c.name AS category_name FROM bar_menu_items mi JOIN bar_categories c ON c.id = mi.category_id WHERE mi.active = 1 ORDER BY c.sort_order, mi.name")->fetchAll();

$menuByCategory = [];
foreach ($items as $item) {
    $menuByCategory[$item['category_name']][] = $item;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e(getSetting('bar_name', 'The Bar')) ?> — Order</title>
    <link rel="stylesheet" href="/bar/public/css/style.css">
    <link href="/bar/public/vendor/inter/inter.css" rel="stylesheet">
    <link rel="stylesheet" href="/bar/public/css/tailwind.build.css">
    <script src="/bar/public/js/swal-helpers.js"></script>
    <style>
        body { font-family: 'Inter Variable', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        .icon { display: inline-block; vertical-align: middle; }
        .icon svg { display: block; }
        .add-badge {
            position: absolute; top: -5px; right: -5px; background: #ef4444; color: white;
            font-size: 10px; font-weight: 700; width: 18px; height: 18px;
            border-radius: 9999px; display: flex; align-items: center; justify-content: center;
        }
        @keyframes bounceAdd {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.15); }
        }
        .animate-bounce-add { animation: bounceAdd 0.25s ease; }
    </style>
</head>
<body class="bg-gray-50">
    <div class="max-w-lg mx-auto p-4 pb-40">
        <div class="text-center mb-6 pt-4">
            <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center mx-auto mb-3 shadow-md">
                <svg viewBox="0 0 24 24" class="w-7 h-7" fill="currentColor"><rect x="6" y="13" width="4" height="8" rx="1"/><rect x="14" y="9" width="4" height="12" rx="1"/><rect x="10" y="5" width="4" height="16" rx="1"/></svg>
            </div>
            <h1 class="text-xl font-bold"><?= e(getSetting('bar_name', 'The Bar')) ?></h1>
            <p class="text-gray-500 text-sm">Table <?= $table['number'] ?></p>
        </div>

        <!-- Categories -->
        <div class="flex gap-2 overflow-x-auto pb-3 mb-4 scrollbar-hide">
            <button class="flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium bg-gray-900 text-white category-btn active" onclick="filterCat('all', this)">All</button>
            <?php foreach ($categories as $cat): ?>
            <button class="flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium bg-white border border-gray-200 text-gray-700 category-btn hover:border-amber-300" onclick="filterCat('<?= e($cat['name']) ?>', this)"><?= e($cat['name']) ?></button>
            <?php endforeach; ?>
        </div>

        <!-- Menu -->
        <div id="menuItems">
            <?php foreach ($menuByCategory as $catName => $catItems): ?>
            <div class="category-group mb-6" data-cat="<?= e($catName) ?>">
                <h3 class="font-bold text-gray-400 text-xs uppercase tracking-wider mb-3 px-1"><?= e($catName) ?></h3>
                <div class="grid grid-cols-2 gap-3">
                    <?php foreach ($catItems as $item): ?>
                    <div class="customer-menu-card" data-id="<?= $item['id'] ?>" data-name="<?= e($item['name']) ?>" data-price="<?= $item['price'] ?>">
                        <div class="customer-menu-card-img">
                            <?php if ($item['image']): ?>
                            <img src="/bar/public/uploads/<?= e($item['image']) ?>" alt="<?= e($item['name']) ?>" loading="lazy">
                            <?php else: ?>
                            <div class="w-full h-full flex items-center justify-center bg-gray-100 text-gray-300"><svg viewBox="0 0 24 24" class="w-8 h-8" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></svg></div>
                            <?php endif; ?>
                            <button type="button" class="customer-menu-card-add" id="addBtn_<?= (int)$item['id'] ?>" onclick='addToCart(<?= (int)$item['id'] ?>, <?= json_encode($item['name']) ?>, <?= (float)$item['price'] ?>)'>
                                <span class="text-white font-bold text-lg leading-none" style="font-family:sans-serif">+</span>
                            </button>
                        </div>
                        <div class="p-2.5">
                            <p class="font-semibold text-sm leading-tight"><?= e($item['name']) ?></p>
                            <?php if ($item['description']): ?>
                            <p class="text-xs text-gray-400 mt-0.5 leading-tight line-clamp-2"><?= e($item['description']) ?></p>
                            <?php endif; ?>
                            <p class="text-amber-600 font-bold text-sm mt-1.5"><?= money($item['price']) ?></p>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>

        <!-- Cart Floating Button -->
        <div id="cartFloating" class="fixed bottom-6 right-6 bg-amber-500 text-white w-14 h-14 rounded-full flex items-center justify-center shadow-lg cursor-pointer hidden z-50 hover:bg-amber-600 transition" onclick="scrollToCart()">
            <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
            <span id="cartBadge" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs w-5 h-5 rounded-full flex items-center justify-center font-bold shadow">0</span>
        </div>

        <!-- Cart Bottom Sheet -->
        <div id="cartSheet" class="customer-cart-sheet hidden">
            <div class="flex items-center justify-between mb-4">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <svg viewBox="0 0 24 24" class="w-5 h-5 text-amber-500" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                    Your Order
                </h3>
                <button onclick="clearCart()" class="text-sm text-red-500 hover:text-red-700 flex items-center gap-1">
                    <svg viewBox="0 0 24 24" class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                    Clear
                </button>
            </div>
            <div id="cartItems" class="max-h-52 overflow-y-auto -mx-1 px-1"></div>
            <div class="pt-4 mt-3" style="border-top: 1px solid #e5e7eb;">
                <p class="text-xs font-semibold text-gray-500 uppercase mb-2">Payment</p>
                <div class="grid grid-cols-2 gap-2 text-sm">
                    <label class="payment-option flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 cursor-pointer">
                        <input type="radio" name="payment_method" value="cash" checked>
                        <span><svg viewBox="0 0 24 24" class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/></svg> Cash</span>
                    </label>
                    <label class="payment-option flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 cursor-pointer">
                        <input type="radio" name="payment_method" value="pos">
                        <span><svg viewBox="0 0 24 24" class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg> POS</span>
                    </label>
                    <label class="payment-option flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 cursor-pointer">
                        <input type="radio" name="payment_method" value="card">
                        <span><svg viewBox="0 0 24 24" class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg> Card</span>
                    </label>
                    <label class="payment-option flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-3 py-2 cursor-pointer">
                        <input type="radio" name="payment_method" value="online">
                        <span><svg viewBox="0 0 24 24" class="w-4 h-4 text-amber-500" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg> Online</span>
                    </label>
                </div>
            </div>
            <div class="flex items-center justify-between pt-4 mt-2" style="border-top: 1px solid #e5e7eb;">
                <div>
                    <span class="text-sm text-gray-500">Total</span>
                    <span class="block font-bold text-xl" id="cartTotal">₦0.00</span>
                </div>
                <button onclick="submitOrder(this)" class="btn btn-accent btn-lg px-8 rounded-full shadow-md">
                    Submit Order <svg viewBox="0 0 24 24" class="w-4 h-4 inline" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                </button>
            </div>
        </div>
    </div>

    <script>
    var cart = JSON.parse(localStorage.getItem('bar_cart_' + <?= $table['id'] ?>)) || [];

    function saveCart() {
        localStorage.setItem('bar_cart_' + <?= $table['id'] ?>, JSON.stringify(cart));
        renderCart();
    }

    function addToCart(id, name, price) {
        var existing = cart.find(function(i) { return i.id === id; });
        if (existing) {
            existing.qty++;
        } else {
            cart.push({ id: id, name: name, price: parseFloat(price), qty: 1 });
        }
        saveCart();
        document.getElementById('cartSheet').classList.remove('hidden');
        document.getElementById('cartFloating').classList.remove('hidden');
        updateAddBtn(id);
        bounceAddBtn(id);
    }

    function updateQty(id, delta) {
        var item = cart.find(function(i) { return i.id === id; });
        if (item) {
            item.qty += delta;
            if (item.qty <= 0) {
                cart = cart.filter(function(i) { return i.id !== id; });
            }
        }
        saveCart();
        updateAddBtn(id);
        if (cart.length === 0) {
            document.getElementById('cartSheet').classList.add('hidden');
            document.getElementById('cartFloating').classList.add('hidden');
        }
    }

    function clearCart() {
        var ids = cart.map(function(i) { return i.id; });
        cart = [];
        saveCart();
        ids.forEach(updateAddBtn);
        document.getElementById('cartSheet').classList.add('hidden');
        document.getElementById('cartFloating').classList.add('hidden');
    }

    function updateAddBtn(id) {
        var btn = document.getElementById('addBtn_' + id);
        if (!btn) return;
        var item = cart.find(function(i) { return i.id === id; });
        if (item && item.qty > 0) {
            btn.innerHTML = '<span class="add-badge">' + item.qty + '</span><span class="text-white font-bold text-lg leading-none" style="font-family:sans-serif">+</span>';
        } else {
            btn.innerHTML = '<span class="text-white font-bold text-lg leading-none" style="font-family:sans-serif">+</span>';
        }
    }

    function bounceAddBtn(id) {
        var btn = document.getElementById('addBtn_' + id);
        if (!btn) return;
        btn.classList.remove('animate-bounce-add');
        void btn.offsetWidth;
        btn.classList.add('animate-bounce-add');
    }

    function renderCart() {
        var container = document.getElementById('cartItems');
        var total = 0;
        var html = '';
        cart.forEach(function(item) {
            total += item.price * item.qty;
            html += '<div class="cart-item"><div><p class="font-medium text-sm">' + item.name + '</p><p class="text-xs text-gray-500">' + formatMoney(item.price) + ' each</p></div><div class="flex items-center gap-2"><button class="qty-btn text-sm" onclick="updateQty(' + item.id + ', -1)">−</button><span class="text-sm font-medium">' + item.qty + '</span><button class="qty-btn text-sm" onclick="updateQty(' + item.id + ', 1)">+</button><span class="text-sm font-bold w-14 text-right">' + formatMoney(item.price * item.qty) + '</span></div></div>';
        });
        container.innerHTML = html || '<p class="text-gray-400 text-sm text-center py-4">Cart is empty</p>';
        document.getElementById('cartTotal').textContent = formatMoney(total);
        document.getElementById('cartBadge').textContent = cart.reduce(function(s, i) { return s + i.qty; }, 0);
    }

    function submitOrder(btn) {
        if (cart.length === 0) return alert('Cart is empty.');
        btn = btn || document.querySelector('#cartSheet button');
        var paymentInput = document.querySelector('input[name="payment_method"]:checked');
        var paymentMethod = paymentInput ? paymentInput.value : 'cash';
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner"></span> Submitting...';

        var xhr = new XMLHttpRequest();
        xhr.open('POST', '/bar/customer/order.php', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.success) {
                        clearCart();
                        var payFlag = paymentMethod === 'online' ? '&pay=1' : '';
                        window.location.href = '/bar/customer/order.php?order_id=' + data.order_id + '&token=<?= $token ?>' + payFlag;
                    } else {
                        btn.disabled = false;
                        btn.innerHTML = 'Submit Order <svg viewBox="0 0 24 24" class="w-4 h-4 inline" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>';
                        alert(data.message || 'Order failed. Please try again.');
                    }
                } catch(e) {
                    btn.disabled = false;
                    btn.innerHTML = 'Submit Order <svg viewBox="0 0 24 24" class="w-4 h-4 inline" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>';
                    alert('Invalid response. Please try again.');
                }
            } else {
                btn.disabled = false;
                btn.innerHTML = 'Submit Order <svg viewBox="0 0 24 24" class="w-4 h-4 inline" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>';
                alert('Server error. Please try again.');
            }
        };
        xhr.onerror = function() {
            btn.disabled = false;
            btn.innerHTML = 'Submit Order <svg viewBox="0 0 24 24" class="w-4 h-4 inline" fill="none" stroke="currentColor" stroke-width="2"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>';
            alert('Network error. Please try again.');
        };
        var params = 'action=submit_order&token=<?= $token ?>&session=<?= $customerSession ?>&payment_method=' + encodeURIComponent(paymentMethod) + '&items=' + encodeURIComponent(JSON.stringify(cart));
        xhr.send(params);
    }

    function scrollToCart() {
        document.getElementById('cartSheet').classList.remove('hidden');
        document.getElementById('cartSheet').scrollIntoView({ behavior: 'smooth' });
    }

    function filterCat(cat, btn) {
        document.querySelectorAll('.category-btn').forEach(function(b) { b.classList.remove('bg-gray-900', 'text-white'); b.classList.add('bg-white', 'border'); });
        btn.classList.add('bg-gray-900', 'text-white');
        btn.classList.remove('bg-white', 'border');
        document.querySelectorAll('.category-group').forEach(function(g) {
            g.style.display = (cat === 'all' || g.dataset.cat === cat) ? '' : 'none';
        });
    }

    function formatMoney(amount) {
        return '₦' + parseFloat(amount).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    renderCart();
    cart.forEach(function(i) { updateAddBtn(i.id); });
    if (cart.length > 0) {
        document.getElementById('cartSheet').classList.remove('hidden');
        document.getElementById('cartFloating').classList.remove('hidden');
    }
    </script>
</body>
</html>
