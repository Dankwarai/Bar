function showToast(message, type) {
    type = type || 'success';
    var icons = { success: 'ri-checkbox-circle-fill', error: 'ri-close-circle-fill', info: 'ri-information-fill' };
    var toast = document.createElement('div');
    toast.className = 'toast toast-' + type;
    toast.innerHTML = '<i class="' + (icons[type] || icons.info) + '"></i> ' + message;
    document.body.appendChild(toast);
    setTimeout(function() { toast.style.transform = 'translateX(100%)'; toast.style.opacity = '0'; toast.style.transition = '0.3s'; setTimeout(function() { toast.remove(); }, 300); }, 3200);
}

function confirmDelete(message) {
    return confirm(message || 'Are you sure?');
}

function formatMoney(amount) {
    return '\u20A6' + parseFloat(amount).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function toggleModal(id) {
    var el = document.getElementById(id);
    if (el) el.classList.toggle('hidden');
}

// ── Loading state on form submissions ──
document.addEventListener('submit', function(e) {
    var form = e.target;
    var btn = form.querySelector('button[type="submit"]');
    if (!btn || btn.dataset.noLoading) return;
    if (btn.classList.contains('btn-loading')) { e.preventDefault(); return; }

    var originalHtml = btn.innerHTML;
    var spinner = '<span class="spinner btn-spinner" style="display:none"></span>';
    btn.innerHTML = spinner + '<span class="btn-text">' + btn.textContent.trim() + '</span>';
    btn.classList.add('btn-loading');
    var spinnerEl = btn.querySelector('.spinner');
    if (spinnerEl) spinnerEl.style.display = 'inline-flex';
});

// ── Sidebar link loading ──
document.addEventListener('click', function(e) {
    var link = e.target.closest('.sidebar-link');
    if (!link || link.getAttribute('href') === '#') return;
    var main = document.querySelector('main');
    if (main) main.style.opacity = '0.5';
});
