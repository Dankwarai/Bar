// POS specific JS — polling for new customer orders
(function() {
    var notified = false;

    function checkNewOrders() {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/bar/pages/pos.php?ajax=pending_orders', true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    if (data.count > 0 && !notified) {
                        showToast(data.count + ' new customer order(s)!', 'success');
                        notified = true;
                    } else if (data.count === 0) {
                        notified = false;
                    }
                } catch(e) {}
            }
        };
        xhr.send();
    }

    setInterval(checkNewOrders, 15000);
})();
