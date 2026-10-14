<?php
// Minimal ESC/POS command builder — no external library, just the handful of
// control sequences needed to print a receipt on a standard 80mm thermal
// printer. Reference: Epson ESC/POS Application Programming Guide.
//
// Currency note: thermal printers commonly use a single-byte codepage (e.g.
// CP437) and will print garbage for a multi-byte UTF-8 character like ₦. To
// stay portable across printer models we don't know, receipts sent to the
// printer use the plain-ASCII "NGN 1,234.50" instead of money()'s "₦1,234.50"
// — the on-screen browser receipt is unaffected and keeps the ₦ symbol.

final class EscPosReceipt
{
    private string $buf = '';

    public function init(): static { $this->buf .= "\x1b\x40"; return $this; } // ESC @ — initialize
    public function bold(bool $on): static { $this->buf .= "\x1b\x45" . ($on ? "\x01" : "\x00"); return $this; }

    public function align(string $mode): static
    {
        $code = match ($mode) { 'center' => "\x01", 'right' => "\x02", default => "\x00" };
        $this->buf .= "\x1b\x61" . $code;
        return $this;
    }

    public function doubleHeight(bool $on): static { $this->buf .= "\x1d\x21" . ($on ? "\x01" : "\x00"); return $this; }
    public function line(string $line = ''): static { $this->buf .= $line . "\n"; return $this; }
    public function feed(int $lines = 1): static { $this->buf .= str_repeat("\n", $lines); return $this; }
    public function cut(): static { $this->buf .= "\x1d\x56\x00"; return $this; } // GS V 0 — full cut
    public function raw(): string { return $this->buf; }
}

function formatMoneyAscii($amount): string
{
    return 'NGN ' . number_format((float)$amount, 2);
}

/** Left-pad a label/value pair to fit an assumed 32-char-wide thermal line (standard for 80mm paper at font A). */
function padReceiptLine(string $label, string $value, int $width = 32): string
{
    $gap = $width - mb_strlen($label) - mb_strlen($value);
    return $label . str_repeat(' ', max(1, $gap)) . $value;
}

/**
 * Build the ESC/POS byte payload for an order receipt — mirrors the layout of
 * the existing browser-print receipt (bar name, items, totals, footer).
 */
function buildReceiptEscPos(array $order, array $items, array $payments, string $barName, string $barAddress, string $footer): string
{
    $orderDate = $order['closed_at'] ?? $order['created_at'];

    $r = new EscPosReceipt();
    $r->init()->align('center')->bold(true)->doubleHeight(true)->line($barName)->doubleHeight(false)->bold(false);
    if ($barAddress !== '') $r->line($barAddress);
    $r->line(date('Y-m-d H:i:s', strtotime($orderDate)))
      ->align('left')
      ->line(str_repeat('-', 32));

    $r->line(padReceiptLine('Order #', (string)$order['id']));
    if (!empty($order['table_number'])) $r->line(padReceiptLine('Table', (string)$order['table_number']));
    $r->line(padReceiptLine('Source', ucfirst($order['source'])));
    if (!empty($order['staff_name'])) $r->line(padReceiptLine('Served by', $order['staff_name']));
    $r->line(str_repeat('-', 32));

    foreach ($items as $item) {
        $label = $item['name'] . ' x' . $item['quantity'];
        $r->line(padReceiptLine($label, formatMoneyAscii($item['quantity'] * $item['unit_price'])));
    }

    $r->line(str_repeat('-', 32));

    // order.subtotal is stored AFTER discount — add discount_amount back to show
    // the true pre-discount subtotal, same reasoning as the on-screen receipt.
    $discAmount = (float)($order['discount_amount'] ?? 0);
    $subtotal   = (float)($order['subtotal'] ?? $order['total']) + $discAmount;
    $tax        = (float)($order['tax_amount'] ?? 0);

    $r->line(padReceiptLine('Subtotal', formatMoneyAscii($subtotal)));
    if ($discAmount > 0) {
        $r->line(padReceiptLine('Discount', '-' . formatMoneyAscii($discAmount)));
    }
    if ($tax > 0) {
        $r->line(padReceiptLine('Tax', formatMoneyAscii($tax)));
    }
    $r->bold(true)->line(padReceiptLine('Total', formatMoneyAscii($order['total'])))->bold(false);

    if ($payments) {
        $r->line(str_repeat('-', 32));
        foreach ($payments as $p) {
            $label = 'Paid via ' . ucfirst($p['method']);
            $r->line(padReceiptLine($label, formatMoneyAscii($p['amount'])));
            if (!empty($p['reference'])) $r->line('  Ref: ' . $p['reference']);
        }
    }

    if ($footer !== '') {
        $r->feed(1)->align('center')->line($footer);
    }

    $r->feed(3)->cut();
    return $r->raw();
}
