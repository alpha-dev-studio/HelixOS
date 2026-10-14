# HelixOS 1.0 “Surge”

HelixOS is a usable desktop OS built on Debian 13 “trixie” — tuned for
older and low-RAM machines (4 GB first, everything else after). Plasma
desktop, Debian package universe, Calamares guided setup and a dual-boot friendly bootloader story out of the box.

Status: pre-alpha. It boots on real hardware from a live USB.
Daily-driver and installer testing is in progress — expect rough edges.

## Try it

1. Build the live ISO (WSL Ubuntu):
   ```bash
   ./scripts/setup-wsl.sh
   ./scripts/make-iso.sh
   ```
2. Grab a 4gb usb stick or more and flash `helixos-live.iso` with Rufus in
   ISO mode (set a persistent partition if you want files/settings to
   survive reboots — needs an 8 GB+ stick). DD mode only as fallback. Secure Boot can stay on
   (signed shim + GRUB); if a firmware complains, retest with it off.
3. Boot the USB, pick Try HelixOS. Live user `helix`, no password.
4. Double-click Install HelixOS for the guided setup (language,
   timezone, keyboard, user + password). preferably on a spare disk.

## Layout

- `scripts/make-iso.sh` — official Debian live-build pipeline + EFI injection
- `scripts/add-efi.sh` — Secure Boot chain + dual BIOS/UEFI image assembly
- `configs/` — GRUB entries, desktop defaults, Calamares branding, lockdown
- `packages/helixos-base/` — base identity deb (OTA channel)
- `docs/ROADMAP.md` — where this is going

## Updates

Installed systems update through APT like any Debian system
(Discover works as the graphical updater). HelixOS system packages
ship through our signed repo; base system tracks Debian trixie.

## Device catalog

HelixOS 1.0 “Surge” ships every firmware package Debian 13 “trixie”
provides, on top of kernel 6.12's built-in drivers. If Debian supports
it, HelixOS boots it. Tested machines are marked ✅, everything else is
expected-to-work but needs a tester.

| Category | Covered hardware | Status |
|---|---|---|
| CPU | Intel 64-bit (Pentium G6400 dev box + microcode) | ✅ boots |
| CPU | AMD Ryzen / EPYC (+ `amd64-microcode`) | wanted tester |
| Graphics | Intel i915 / Xe (`firmware-intel-graphics`) | ✅ boots |
| Graphics | AMD Radeon / RDNA (`firmware-amd-graphics`) | wanted tester |
| Graphics | NVIDIA (`firmware-nvidia-graphics`, nouveau) | wanted tester |
| Graphics | Aspeed BMC (`firmware-ast`) | untested |
| WiFi | Intel Wireless (`firmware-iwlwifi`) | wanted tester |
| WiFi | Realtek (`firmware-realtek`) | wanted tester |
| WiFi | Atheros (`firmware-atheros`) | wanted tester |
| WiFi | Broadcom (`firmware-brcm80211`) | wanted tester |
| WiFi | MediaTek (`firmware-mediatek`) | wanted tester |
| WiFi | Marvell / Libertas, legacy ipw2x00 / zd1211 USB | untested |
| Ethernet | Intel, Realtek, Broadcom bnx2/bnx2x, Marvell, Cavium, Netronome, Myricom, QLogic, Netxen | expected ✅ |
| Audio | Intel SOF + Intel HDA (`firmware-sof-signed`, `firmware-intel-sound`), Cirrus | wanted tester |
| Bluetooth | Intel / Realtek / Atheros / MediaTek (`bluez-firmware` + wifi bundles) | wanted tester |
| Other | TV (ivtv, siano), telephony (dahdi), Atmel sensors | untested |

Minimum target: 4 GB RAM, 64-bit UEFI or BIOS, 4 GB USB stick.
Known gap: exotic Broadcom chips needing `broadcom-sta-dkms` and brand-new
Realtek chips — report `lspci -nn` output and they get added.

## Contribute

Testers wanted — especially AMD CPUs and old 4 GB machines.
Boot the live USB, fill the hardware sheet in Issues, paste failures
with photos of the screen. Docs, translations, and packaging help
welcome. Be kind, paste logs.

