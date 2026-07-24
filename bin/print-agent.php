<?php
/**
 * Local thermal print agent — run this ON the POS terminal itself, the
 * machine physically connected to the USB thermal printer. It's a separate,
 * standalone process from the main web app (which may be running on a
 * different machine on the LAN) — a browser can't talk to a USB device
 * directly, so this small localhost-only service bridges the gap: the POS
 * page's JS sends it raw ESC/POS bytes over HTTP, and it writes them straight
 * to the printer.
 *
 * Start it with:
 *   php -S 127.0.0.1:9100 bin/print-agent.php
 *
 * For it to survive reboots/crashes, run it under a process supervisor
 * instead of a bare terminal — see PRINTING.md for a sample systemd unit.
 *
 * Printer device path — override with the PRINTER_DEVICE env var if yours
 * differs:
 *   PRINTER_DEVICE=/dev/usb/lp0 php -S 127.0.0.1:9100 bin/print-agent.php
 *
 * On Linux, a USB thermal printer registered as a raw USB printer-class
 * device usually shows up at /dev/usb/lp0 (or lp1, lp2, ... if you have more
 * than one). If yours is set up as a CUPS queue instead, set
 * PRINTER_DEVICE=lp:<queue-name> to pipe through `lp -d <queue> -o raw`.
 *
 * NOT tested against real hardware — device paths and permissions vary by
 * printer, distro, and udev configuration. You will likely need to adjust
 * PRINTER_DEVICE and/or grant this process permission to write to it (e.g.
 * add the running user to the `lp` group, or add a udev rule).
 *
 * Auth — set PRINT_AGENT_TOKEN to the same value as Settings → Thermal
 * Printer → Print Agent Token in the app. Without it, anything running in
 * the same browser as the POS terminal (e.g. a malicious page in another
 * tab) could silently trigger a print — this agent has no other access
 * control since it only binds to 127.0.0.1, not the network.
 *   PRINT_AGENT_TOKEN=abc123 php -S 127.0.0.1:9100 bin/print-agent.php
 */

header('Access-Control-Allow-Origin: *'); // the POS page and this agent are on different origins (app host vs 127.0.0.1) — the real access control is the PRINT_AGENT_TOKEN check below, not CORS
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Print-Agent-Token');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$path = parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH);

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || $path !== '/print') {
    http_response_code(404);
    exit(json_encode(['ok' => false, 'error' => 'Not found. POST raw ESC/POS bytes (base64-encoded) to /print.']));
}

$expectedToken = getenv('PRINT_AGENT_TOKEN');
if ($expectedToken !== false && $expectedToken !== '') {
    $givenToken = $_SERVER['HTTP_X_PRINT_AGENT_TOKEN'] ?? '';
    if (!hash_equals($expectedToken, $givenToken)) {
        http_response_code(403);
        exit(json_encode(['ok' => false, 'error' => 'Invalid or missing print agent token.']));
    }
}

$body = json_decode(file_get_contents('php://input'), true);
$b64  = is_array($body) ? ($body['data'] ?? '') : '';
$raw  = $b64 !== '' ? base64_decode($b64, true) : false;

if ($raw === false || $raw === '') {
    http_response_code(400);
    exit(json_encode(['ok' => false, 'error' => 'Missing or invalid "data" field (expected base64-encoded ESC/POS bytes).']));
}

$device = getenv('PRINTER_DEVICE') ?: '/dev/usb/lp0';

if (str_starts_with($device, 'lp:')) {
    // CUPS queue fallback — pipe raw bytes through `lp -d <queue> -o raw`
    $queue = substr($device, 3);
    $descriptors = [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']];
    $proc = proc_open(['lp', '-d', $queue, '-o', 'raw'], $descriptors, $pipes);
    if (!is_resource($proc)) {
        http_response_code(500);
        exit(json_encode(['ok' => false, 'error' => 'Could not start lp. Is CUPS installed?']));
    }
    fwrite($pipes[0], $raw);
    fclose($pipes[0]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);
    $exitCode = proc_close($proc);

    if ($exitCode !== 0) {
        http_response_code(500);
        exit(json_encode(['ok' => false, 'error' => "lp exited with code {$exitCode}: {$stderr}"]));
    }
    echo json_encode(['ok' => true, 'via' => 'cups', 'queue' => $queue]);
    exit;
}

// Direct raw-device write — typical for a USB printer-class device like /dev/usb/lp0
$fh = @fopen($device, 'wb');
if (!$fh) {
    http_response_code(500);
    exit(json_encode([
        'ok'    => false,
        'error' => "Could not open printer device '{$device}'. Check the path exists and this process " .
                   "has permission to write to it (try adding the running user to the 'lp' group).",
    ]));
}
$written = fwrite($fh, $raw);
fclose($fh);

if ($written === false || $written < strlen($raw)) {
    http_response_code(500);
    exit(json_encode(['ok' => false, 'error' => 'Write to printer device failed or was incomplete.']));
}

echo json_encode(['ok' => true, 'via' => 'device', 'device' => $device, 'bytes' => $written]);
