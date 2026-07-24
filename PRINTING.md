# Thermal Printer Setup (USB, Linux)

The POS receipt page has a **"Print via Thermal Printer"** button alongside the
existing browser-print button. It talks to a small local agent
(`bin/print-agent.php`) that must be running **on the same machine the USB
printer is plugged into** — a browser can't write to a USB device directly, so
this agent bridges the gap: the POS page sends it raw ESC/POS bytes over HTTP,
and it writes them straight to the printer.

This was built for a Linux POS terminal (matching the environment this app was
developed in) and has **not been tested against real printer hardware** —
device paths, permissions, and even which mechanism your printer expects vary
by model and distro. Treat the defaults below as a starting point, not a
guarantee.

## 0. Set an auth token (recommended)

The agent only listens on `127.0.0.1`, so it's not reachable over the network
— but it *is* reachable from anything else running in the same browser on
that machine, including a malicious page in another tab, since it has no
access control by default. Close that off:

1. In the app: **Settings → Thermal Printer → Print Agent Token** → click
   **Generate**, then **Save Settings**.
2. Pass the same value to the agent via `PRINT_AGENT_TOKEN` (see step 3 below).

If you skip this, the agent still works — it just trusts any request that
reaches it.

## 1. Find your printer

```bash
ls /dev/usb/lp*
```

A USB thermal printer registered as a raw USB printer-class device usually
shows up as `/dev/usb/lp0` (or `lp1`, `lp2`, ... if you have more than one
printer, or if the numbering has shifted since the last reboot).

If nothing shows up there, your printer may instead be set up as a **CUPS
queue**. Check with:

```bash
lpstat -p
```

## 2. Permissions

The agent needs permission to write to the device file. The usual fix is
adding the user that will run the agent to the `lp` group:

```bash
sudo usermod -aG lp $USER
# log out and back in for the group change to take effect
```

If that's not enough on your distro, you may need a udev rule granting group
`lp` write access to the specific device — this varies enough by
printer/distro that it's outside what a generic script can handle for you.

## 3. Run the agent

```bash
cd /path/to/Bar
php -S 127.0.0.1:9100 bin/print-agent.php
```

If your printer isn't at `/dev/usb/lp0`, override it:

```bash
PRINTER_DEVICE=/dev/usb/lp1 php -S 127.0.0.1:9100 bin/print-agent.php
```

If you're printing through a CUPS queue instead of a raw device, point it at
the queue name with an `lp:` prefix:

```bash
PRINTER_DEVICE=lp:MyThermalPrinter php -S 127.0.0.1:9100 bin/print-agent.php
```

With the token from step 0 (combine env vars as needed):

```bash
PRINT_AGENT_TOKEN=paste-the-generated-token-here php -S 127.0.0.1:9100 bin/print-agent.php
```

## 4. Keep it running (systemd)

A bare terminal process dies when the terminal closes or the machine reboots.
For a POS terminal that needs to survive both, run it as a systemd service.
Create `/etc/systemd/system/bar-print-agent.service`:

```ini
[Unit]
Description=Bar Management System — local thermal print agent
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/path/to/Bar
Environment=PRINTER_DEVICE=/dev/usb/lp0
Environment=PRINT_AGENT_TOKEN=paste-the-generated-token-here
ExecStart=/usr/bin/php -S 127.0.0.1:9100 bin/print-agent.php
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now bar-print-agent
sudo systemctl status bar-print-agent
```

## 5. Test it

From the POS terminal (the agent only listens on `127.0.0.1`, so this must run
on the same machine):

```bash
curl -i http://127.0.0.1:9100/print \
  -H 'Content-Type: application/json' \
  -d '{"data":"G0AbYQFURVNUUFJJTlQKG2EA"}'
```

That payload is a tiny "TESTPRINT" ESC/POS sequence (init, center-align,
print the word, reset alignment) — generated and verified with:

```bash
php -r '
$payload = "\x1b\x40" . "\x1b\x61\x01" . "TESTPRINT\n" . "\x1b\x61\x00";
echo base64_encode($payload) . "\n";
'
```

If it prints, the agent and printer are wired up correctly and the "Print via
Thermal Printer" button on the POS receipt screen will work.

## Troubleshooting

- **"Could not reach the local print agent"** (shown on the POS page) — the
  agent isn't running, or isn't running on the same machine as the browser.
  Remember: `127.0.0.1` on the *browser's* machine, not the app server, if
  they're different machines.
- **"Could not open printer device"** — check `PRINTER_DEVICE` points at a
  path that exists (`ls /dev/usb/lp*`) and that the agent's user has
  permission to write to it (see step 2).
- **"Invalid or missing print agent token"** — the value in Settings →
  Thermal Printer doesn't match the agent's `PRINT_AGENT_TOKEN` env var.
  Regenerate one and update both places, or clear the Settings field to
  turn the check off entirely.
- **Garbled/wrong characters print** — the receipt uses plain ASCII (`NGN
  1,234.50` instead of `₦1,234.50`) specifically to avoid this, since most
  thermal printers use a single-byte codepage that can't render the ₦ symbol.
  If you still see garbling, your printer may expect a different codepage
  select command than what's built into `includes/escpos.php` — this would
  need adjusting per printer model.
