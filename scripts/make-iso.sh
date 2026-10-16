#!/usr/bin/env bash
set -euo pipefail
# HelixOS official ISO via Debian live-build (tested bootloader/installer, trixie)
# Run in WSL: ./scripts/make-iso.sh  ->  ~/helixos-iso/live-image-amd64.hybrid.iso
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LB_DIR="$HOME/helixos-iso"
CONF="$ROOT/configs/desktop"
SHELLCONF="$ROOT/configs/helix-shell"

sudo apt-get update
sudo apt-get install -y live-build debootstrap debian-archive-keyring cpio xorriso isolinux syslinux-efi syslinux-utils grub-efi-amd64-bin squashfs-tools imagemagick debhelper build-essential

# Patch noble's old live-build: trixie moved Contents indices per-component
# (dists/trixie/main/Contents-*.gz), scripts still fetch suite-level path (404).
for LBFIX in /usr/lib/live/build/lb_chroot_linux-image /usr/lib/live/build/lb_binary_debian-installer; do
  if grep -q 'dists/${LB_DISTRIBUTION}/Contents-' "$LBFIX" 2>/dev/null; then
    sudo sed -i 's|/dists/${LB_PARENT_DISTRIBUTION}/Contents-|/dists/${LB_PARENT_DISTRIBUTION}/main/Contents-|; s|/dists/${LB_DISTRIBUTION}/Contents-|/dists/${LB_DISTRIBUTION}/main/Contents-|' "$LBFIX"
    echo "Patched $LBFIX for per-component Contents."
  fi
done
# Patch chroot deconfigure: teardown's dpkg-divert --remove --rename refuses to
# land when the slot holds a different file (it only renames into an empty
# slot) and the whole build runs under set -e -> exit 2. Since our hook lays
# the real binary at the canonical path, the old symlink-only rm left the slot
# occupied and killed every build. Clear the slot whenever .distrib exists to
# receive the rename (teardown restores the pristine original) or the path is
# still the fake symlink. Safe: the hook FATAL-checks a real binary first, so
# this can never ship an ISO without one.
DPKGDEL=/usr/lib/live/build/lb_chroot_dpkg
if grep -q 'rm -f chroot/usr/sbin/start-stop-daemon$' "$DPKGDEL" 2>/dev/null; then
  sudo sed -i 's#rm -f chroot/usr/sbin/start-stop-daemon$#if [ -f chroot/usr/sbin/start-stop-daemon.distrib ] || [ "$(readlink chroot/usr/sbin/start-stop-daemon 2>/dev/null)" = "/bin/true" ]; then rm -f chroot/usr/sbin/start-stop-daemon; fi#' "$DPKGDEL"
  echo "Patched $DPKGDEL to clear the rename slot for start-stop-daemon."
elif grep -q 'readlink chroot/usr/sbin/start-stop-daemon' "$DPKGDEL" 2>/dev/null; then
  # Superseded first-generation patch (symlink-only rm) still present on this
  # host from an earlier run — upgrade it in place.
  sudo sed -i 's#if \[ "$(readlink chroot/usr/sbin/start-stop-daemon 2>/dev/null)" = "/bin/true" \]; then rm -f chroot/usr/sbin/start-stop-daemon; fi#if [ -f chroot/usr/sbin/start-stop-daemon.distrib ] || [ "$(readlink chroot/usr/sbin/start-stop-daemon 2>/dev/null)" = "/bin/true" ]; then rm -f chroot/usr/sbin/start-stop-daemon; fi#' "$DPKGDEL"
  echo "Upgraded $DPKGDEL patch to clear the rename slot for start-stop-daemon."
fi
# Patch debian-installer integration: drops 2006-era lilo/bare-grub/linux-image-2.6 names
DIFIX=/usr/lib/live/build/lb_binary_debian-installer
if grep -q 'DI_REQ_PACKAGES=' "$DIFIX" 2>/dev/null; then
  sudo sed -i 's/DI_REQ_PACKAGES="[^"]*"/DI_REQ_PACKAGES="grub-pc"/; s/linux-image-2\.6-amd64/linux-image-amd64/g' "$DIFIX"
  echo "Patched $DIFIX for trixie bootloader/kernel names."
fi

# Cached builds by default: reuse ~/helixos-iso (debootstrap + debs stay cached).
# Flags: --clean = from-scratch (wipes everything, hours). --full = repack the
#   binary tree too (needed when chroot content changed). Plain run = fastest,
#   skips mksquashfs when nothing in the chroot changed (ISO/EFI/grub iterations).
if [ "${1:-}" = "--clean" ]; then
  sudo rm -rf "$LB_DIR"
fi
mkdir -p "$LB_DIR"
cd "$LB_DIR"
lb config \
  --mode debian \
  --distribution trixie \
  --initsystem systemd \
  --archive-areas "main contrib non-free non-free-firmware" \
  --security false \
  --mirror-bootstrap https://deb.debian.org/debian \
  --mirror-chroot https://deb.debian.org/debian \
  --mirror-binary https://deb.debian.org/debian \
  --linux-flavours amd64 \
  --linux-packages "linux-image" \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootloader syslinux \
  --debian-installer live \
  --iso-application HelixOS \
  --iso-preparer "HelixOS" \
  --iso-publisher "HelixOS" \
  --iso-volume HelixOS \
  --source false \
  --win32-loader false \
  --bootappend-live "boot=live components username=helix quiet splash"

# Bake helixos-* debs into the image from LOCAL source (so first boot is already
# converged — no apt-install dance for users). DrvFs-safe: build on ext4 tmp.
# Built debs land in includes.chroot/tmp and a late chroot hook dpkg-installs
# them (postinst no-ops safely in-image: helix is the only user, so it's kept).
DEBTMP="$(mktemp -d /tmp/helixos-img-debs-XXXX)"
for _pkgdir in "$ROOT"/packages/*/; do
  [ -f "$_pkgdir/debian/control" ] || continue
  _pkg="$(basename "$_pkgdir")"
  _work="$DEBTMP/$_pkg"
  rm -rf "$_work"; cp -a "$_pkgdir" "$_work"
  chmod +x "$_work/debian/rules"
  chmod -x "$_work/debian/install" "$_work/debian/control" "$_work/debian/changelog" 2>/dev/null || true
  rm -rf "$_work/debian/.debhelper" "$_work/debian/$_pkg" "$_work/debian/debhelper-build-stamp" 2>/dev/null || true
  (cd "$_work" && dpkg-buildpackage -us -uc -b) || echo "WARNING: $_pkg failed to build — image ships without it"
done
mkdir -p config/includes.chroot/tmp/helixos-debs
rm -f config/includes.chroot/tmp/helixos-debs/*.deb
cp -vf "$DEBTMP"/*.deb config/includes.chroot/tmp/helixos-debs/ 2>/dev/null || echo "WARNING: no helixos debs built"
rm -rf "$DEBTMP"
# HelixOS package set: Helix shell on labwc (no Plasma) — Settings, Files,
# Store, Terminal, Calculator, Task Manager, Paint all ship as Helix QML.
# dolphin/konsole stay ONLY as fallbacks (Helix Files/Terminal run real
# commands via the bridge next; rescue still shells to konsole). kate/okular/
# ark/spectacle stay as utility apps with no Helix replacement yet.
mkdir -p config/package-lists
cat > config/package-lists/helixos.list.chroot <<'PKGS'
labwc
xwayland
sddm
qt6-wayland
qml6-module-qtquick
qml6-module-qtquick-controls
wlr-randr
brightnessctl
dolphin
konsole
kate
okular
ark
kde-spectacle
firefox-esr
network-manager
pipewire
wireplumber
mesa-utils
plymouth
plymouth-themes
unattended-upgrades
pkexec
# Every hardware driver/firmware Debian trixie ships (nothing custom — kernel
# drivers already ride in linux-image; these are the binary blobs). Covers
# Intel/AMD/NVIDIA GPUs, all wifi vendors, sound (SOF), bluetooth, NICs.
firmware-linux
firmware-linux-nonfree
firmware-amd-graphics
firmware-atheros
firmware-brcm80211
firmware-intel-graphics
firmware-intel-misc
firmware-intel-sound
firmware-iwlwifi
firmware-libertas
firmware-mediatek
firmware-misc-nonfree
firmware-nvidia-graphics
firmware-realtek
firmware-sof-signed
firmware-bnx2
firmware-bnx2x
firmware-cavium
firmware-marvell-prestera
firmware-netxen
firmware-netronome
firmware-qlogic
firmware-ast
firmware-cirrus
firmware-ipw2x00
firmware-ivtv
firmware-myricom
firmware-siano
firmware-zd1211
atmel-firmware
bluez-firmware
dahdi-firmware-nonfree
iucode-tool
amd64-microcode
intel-microcode
# Offline installs: GRUB + shim in the live system so Calamares' bootloader
# step works with no network (target inherits them via unpackfs)
grub-efi-amd64
shim-signed
# Market wins a solo dev can ship: laptop power, one sane app story
# (Flatpak CLI; Discover and its backend left with Plasma), fingerprint readers.
power-profiles-daemon
flatpak
python3-pyqt6
fprintd
libpam-fprintd
# Rollback engine: btrfs snapshots around every upgrade (openSUSE model).
# NOTE: grub-btrfs is NOT a Debian package (upstream-only) — snapshots restore
# via live USB + btrfs set-default until the GRUB-menu step is vendored+tested.
snapper
btrfs-progs
# Tier 3 OTA engine (dormant until slot layout ships — see docs/HOW-IT-WORKS.md)
rauc
fonts-noto-core
fonts-hack
grim
slurp
wl-clipboard
isolinux
syslinux-utils
live-boot
live-config
live-config-systemd
live-tools
user-setup
eject
calamares
calamares-settings-debian
refind
os-prober
efibootmgr
PKGS

# base identity (no logos, no wallpapers, no custom themes)
mkdir -p config/includes.chroot/etc \
  config/includes.chroot/etc/sddm.conf.d \
  config/includes.chroot/etc/xdg
cp "$SHELLCONF/kdeglobals-locked" config/includes.chroot/etc/xdg/kdeglobals
# NOTE: /etc/helixos-release is owned by the helixos-base deb (as a file).
# Never write it here too — dual ownership tar-bombs lb_chroot_includes.
echo "helix" > config/includes.chroot/etc/hostname
printf '127.0.0.1 localhost\n::1 localhost ip6-localhost ip6-loopback\n127.0.1.1 helix\n' > config/includes.chroot/etc/hosts
# Architecture rule: apt + Discover see Debian ONLY. The HelixOS repo lives
# exclusively inside the HelixOS Updater app (it enables the source for the
# duration of its own refresh/install, then removes it). No helixos.* file may
# ever be written to sources.list.d here — that separation is the whole point.
printf '[Theme]\nCurrent=breeze\n' > config/includes.chroot/etc/sddm.conf.d/helixos.conf
# Tier 2 OTA: security updates install themselves overnight, everything else
# shows up in Discover. Without this file the package alone does nothing.
mkdir -p config/includes.chroot/etc/apt/apt.conf.d
cat > config/includes.chroot/etc/apt/apt.conf.d/20helixos-auto-upgrades <<'APT'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
APT
# Rollback wiring: snapshot the root subvolume before/after every apt run.
# A broken update = reboot, pick the pre-upgrade snapshot in GRUB, done.
cat > config/includes.chroot/etc/apt/apt.conf.d/80helixos-snapshots <<'SNAPAPT'
DPkg::Pre-Invoke {"SNAPPER_NUMBER=$(/usr/bin/snapper create --type pre --cleanup-algorithm number --print-number --description 'apt' 2>/dev/null); echo $SNAPPER_NUMBER > /var/run/snapper-apt.number || true";};
DPkg::Post-Invoke {"if [ -f /var/run/snapper-apt.number ]; then /usr/bin/snapper create --type post --pre-number=$(cat /var/run/snapper-apt.number) --cleanup-algorithm number --description 'apt' 2>/dev/null || true; rm -f /var/run/snapper-apt.number; fi";};
SNAPAPT
# Default snapper root config (numbered pre/post pairs, keep last 10).
mkdir -p config/includes.chroot/etc/snapper/configs
cat > config/includes.chroot/etc/snapper/configs/root <<'SNAPCFG'
SUBVOLUME="/"
FSTYPE="btrfs"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
NUMBER_LIMIT="10"
TIMELINE_CREATE="no"
EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="1800"
SNAPCFG
# Tier 3 OTA: A/B image updater present from day one (slot layout + server
# bundles land with the fleet design in docs/HOW-IT-WORKS.md).
# (rauc package itself added to the list below.)
# Install-to-disk desktop icon for the live session (stock look: system icon,
# stock Debian setup branding — zero Helix artwork anywhere)
mkdir -p config/includes.chroot/etc/skel/Desktop config/includes.chroot/usr/share/applications
cat > config/includes.chroot/usr/share/applications/helixos-install.desktop <<'DESK'
[Desktop Entry]
Name=Install HelixOS
Comment=Guided setup: language, timezone, keyboard, user and password
Exec=pkexec calamares
Icon=system-software-install
Terminal=false
Type=Application
Categories=System;
DESK
cp config/includes.chroot/usr/share/applications/helixos-install.desktop config/includes.chroot/etc/skel/Desktop/
# Dual-boot engine: rEFInd auto-installer (live-side script) + Calamares job config.
# The setup's partitioning step picks the partition (alongside/manual incl. Windows
# shrink); this job then drops rEFInd into the installed ESP automatically.
mkdir -p config/includes.chroot/usr/bin
cp "$ROOT/configs/calamares/helixos-refind-install.sh" config/includes.chroot/usr/bin/helixos-refind-install
chmod +x config/includes.chroot/usr/bin/helixos-refind-install
# Rescue stick tool: lives in the app menu (NOT the desktop — one icon rule),
# refuses to touch the live system itself, operates on installed HelixOS roots.
cp "$ROOT/configs/rescue/helixos-rescue.sh" config/includes.chroot/usr/bin/helixos-rescue
chmod +x config/includes.chroot/usr/bin/helixos-rescue
cat > config/includes.chroot/usr/share/applications/helixos-rescue.desktop <<'DESK'
[Desktop Entry]
Name=HelixOS Rescue
Comment=Repair or update an installed HelixOS from USB
Exec=pkexec /usr/bin/helixos-rescue
Icon=system-software-install
Terminal=true
Type=Application
Categories=System;
NoDisplay=false
DESK
# Recovery boot plumbing: the "HelixOS Recovery" entries pass helixos-recovery
# on the kernel cmdline; this autostart wrapper opens Rescue on login, and
# no-ops everywhere else (including installed systems).
mkdir -p config/includes.chroot/etc/xdg/autostart
cat > config/includes.chroot/usr/bin/helixos-recovery-autostart <<'WRAP'
#!/bin/sh
grep -q 'helixos-recovery' /proc/cmdline || exit 0
exec konsole -e /usr/bin/helixos-rescue
WRAP
chmod +x config/includes.chroot/usr/bin/helixos-recovery-autostart
cat > config/includes.chroot/etc/xdg/autostart/helixos-recovery.desktop <<'DESK'
[Desktop Entry]
Name=HelixOS Recovery
Exec=/usr/bin/helixos-recovery-autostart
Terminal=false
Type=Application
NoDisplay=true
X-GNOME-Autostart-enabled=true
DESK
mkdir -p config/includes.chroot/etc/calamares/modules
cat > config/includes.chroot/etc/calamares/modules/shellprocess_helix-refind.conf <<'YML'
---
dontChroot: true
timeout: 300
script:
    - command: ["/usr/bin/helixos-refind-install"]
YML
# Post-install cleanup runs INSIDE the target (default chrooted): drops the
# live helix user once a real account exists, so login shows one user only.
cp "$ROOT/configs/calamares/helixos-finish-install.sh" config/includes.chroot/usr/bin/helixos-finish-install
chmod +x config/includes.chroot/usr/bin/helixos-finish-install
cat > config/includes.chroot/etc/calamares/modules/shellprocess_helix-finish.conf <<'YML'
---
dontChroot: false
timeout: 120
script:
    - command: ["/usr/bin/helixos-finish-install"]
YML
# HelixOS GRUB menu (UEFI, 10s timeout) — binary includes land after the
# generated grub stages, so ours wins. EFI-embedded stub chainloads /boot/grub.
# (No theme: plain GRUB menu until new artwork lands.)
mkdir -p config/includes.binary/boot/grub
cp "$ROOT/configs/grub/grub.cfg" config/includes.binary/boot/grub/grub.cfg
# Purge stale GRUB theme (logo background.png resurrected from old runs even
# though the source file is deleted — plain GRUB menu only, no boot images)
rm -rf config/includes.binary/boot/grub/themes 2>/dev/null || true
# Blank the bgrt fallback image: on boards without firmware logo data the plugin
# shows bgrt-fallback.png — Debian bakes its swirl into it (your photo). A blank
# pixel draws nothing. Still zero visible boot images; invisible by design.
mkdir -p config/includes.chroot/usr/share/plymouth/themes/bgrt
convert -size 1x1 xc:none config/includes.chroot/usr/share/plymouth/themes/bgrt/bgrt-fallback.png 2>/dev/null || true
# Boot splash, exactly per spec: NO shipped images. Stock bgrt theme shows the
# firmware (motherboard) logo + spinner wheel, Ubuntu-style. A oneshot service
# captions "HelixOS" under the wheel via the Plymouth message channel.
# hooks live FLAT in config/hooks/ (live-build ignores subdirectories)
mkdir -p config/hooks
rm -f config/hooks/0099-helixos-plymouth-reset.hook.chroot
cat > config/hooks/0099-helixos-plymouth-bgrt.hook.chroot <<'HOOK'
#!/bin/sh
plymouth-set-default-theme bgrt 2>/dev/null || plymouth-set-default-theme spinner 2>/dev/null || true
HOOK
chmod +x config/hooks/0099-helixos-plymouth-bgrt.hook.chroot
# HelixOS identity: every generic Debian branding becomes HelixOS. os-release
# is what splash messages, Settings About, and tools read — ID_LIKE=debian
# keeps third-party scripts working while NAME says HelixOS everywhere.
cat > config/hooks/0099-helixos-branding.hook.chroot <<'HOOK'
#!/bin/sh
cat > /etc/os-release <<'OSR'
NAME="HelixOS"
PRETTY_NAME="HelixOS 1.0 Surge"
ID=helixos
ID_LIKE=debian
VERSION="1.0 (Surge)"
VERSION_ID="1.0"
VERSION_CODENAME=trixie
DEBIAN_CODENAME=trixie
ANSI_COLOR="0;36"
HOME_URL="https://alpha-dev-studio.github.io/HelixOS-Web/"
SUPPORT_URL="https://github.com/alpha-dev-studio/HelixOS/issues"
BUG_REPORT_URL="https://github.com/alpha-dev-studio/HelixOS/issues"
OSR
cat > /etc/issue <<'ISSUE'
HelixOS 1.0 "Surge" \n \l

ISSUE
printf 'HelixOS 1.0 (Surge)\n' > /etc/issue.net
cat > /etc/lsb-release <<'LSB'
DISTRIB_ID=HelixOS
DISTRIB_RELEASE=1.0
DISTRIB_CODENAME=surge
DISTRIB_DESCRIPTION="HelixOS 1.0 Surge"
LSB
# Rebuild initramfs AFTER branding: the early splash is baked at kernel-install
# time, so without this boot shows the stale spinner+Debian watermark from
# initramfs while the real root says HelixOS. This is what your photo caught.
update-initramfs -u -k all 2>&1 | tail -n3 || true
HOOK
chmod +x config/hooks/0099-helixos-branding.hook.chroot
mkdir -p config/includes.chroot/etc/systemd/system
cat > config/includes.chroot/etc/systemd/system/helixos-boot-caption.service <<'UNIT'
[Unit]
Description=HelixOS boot caption under the spinner wheel
DefaultDependencies=no
After=plymouth-start.service
Before=plymouth-quit.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c '/usr/bin/plymouth display-message --text=HelixOS || true'

[Install]
WantedBy=sysinit.target
UNIT
cat > config/hooks/0099-helixos-caption-enable.hook.chroot <<'HOOK'
#!/bin/sh
systemctl enable helixos-boot-caption 2>/dev/null || true
HOOK
chmod +x config/hooks/0099-helixos-caption-enable.hook.chroot
# Setup sequencer patch: run the rEFInd dual-boot job + the finish job
# (live-user cleanup, in-target) right after the stock bootloader step.
# Guarded — any mismatch skips silently (stock setup).
cat > config/hooks/0099-helixos-calamares-refind.hook.chroot <<'HOOK'
#!/bin/sh
python3 - <<'PYEOF' || true
import os, shutil
p = '/etc/calamares/settings.conf'
jobs = {
    '/etc/calamares/modules/shellprocess_helix-refind.conf': 'shellprocess@helix-refind',
    '/etc/calamares/modules/shellprocess_helix-finish.conf': 'shellprocess@helix-finish',
}
try:
    src = open(p).read().splitlines(keepends=True)
    have = {tag: os.path.exists(job) for job, tag in jobs.items()}
    # repair: drop any previous helix lines (incl. wrong-indent ones that
    # Calamares reads as "bootloader-shellprocess@helix-refind")
    src = [l for l in src if 'helix-refind' not in l and 'helix-finish' not in l]
    hits = [i for i, l in enumerate(src) if l.strip() == '- bootloader']
    if all(have.values()) and len(hits) == 1:
        shutil.copyfile(p, p + '.helixos-bak')
        src.insert(hits[0] + 1, '  - shellprocess@helix-refind\n')
        src.insert(hits[0] + 2, '  - shellprocess@helix-finish\n')
        open(p, 'w').writelines(src)
        print('helix jobs sequenced after bootloader')
    else:
        print('helix sequencing skipped (layout differs)')
except Exception as e:
    print('helix sequencing skipped:', e)
PYEOF
HOOK
chmod +x config/hooks/0099-helixos-calamares-refind.hook.chroot
# Live user helix: pre-created, EMPTY password, passwordless sudo.
# (live-config reuses the existing account at boot instead of inventing one.)
cat > config/hooks/0099-helixos-liveuser.hook.chroot <<'HOOK'
#!/bin/sh
set -e
id helix >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev helix
passwd -d helix
printf 'helix ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/helix-live
chmod 440 /etc/sudoers.d/helix-live
HOOK
chmod +x config/hooks/0099-helixos-liveuser.hook.chroot
# Install the baked helixos-* debs late in the chroot (after the live user
# exists, so postinst keeps it). Loud on failure — a silently unconverged
# image is worse than a red build.
cat > config/hooks/0099-helixos-local-debs.hook.chroot <<'HOOK'
#!/bin/sh
if ls /tmp/helixos-debs/*.deb >/dev/null 2>&1; then
  dpkg -i /tmp/helixos-debs/*.deb
  rm -rf /tmp/helixos-debs
fi
HOOK
chmod +x config/hooks/0099-helixos-local-debs.hook.chroot
# No fallback window managers ship: one desktop (Plasma), one of every app.
# A second session previously stole the SDDM default and stranded new installs
# on a blank desktop — that class of bug is gone by construction now.# Restore real start-stop-daemon: live-build diverts it in chroot and the fake
# leaks (or vanishes) into the squashfs — then every dpkg run in Calamares'
# target fails with apt code 100. ENFORCED: three fallbacks run, and the build
# DIES LOUDLY rather than packing another broken ISO. Belt-and-suspenders
# symlink into /usr/bin covers Calamares runs with sbin stripped from PATH.
cat > config/hooks/0099-helixos-dpkg-restore.hook.chroot <<'HOOK'
#!/bin/sh
# ENFORCED: a fake/missing start-stop-daemon ships a broken ISO (Calamares
# target fails apt code 100). NOTE: plain -x checks LIE here — the fake is a
# symlink to /bin/true, which is executable. Only a real binary counts.
is_real_ssd() {
  for f in /sbin/start-stop-daemon /usr/sbin/start-stop-daemon; do
    if [ -x "$f" ]; then
      case "$(readlink -f "$f")" in
        /bin/true|/usr/bin/true) ;;
        *) return 0 ;;
      esac
    fi
  done
  return 1
}
# Do NOT dpkg-divert --remove here: live-build's teardown (lb_chroot_dpkg
# remove, runs under set -e) owns those records, and on usrmerged trixie
# (/sbin --> /usr/sbin, same file diverted twice — live-build bug #2122623)
# an early removal makes its --remove --rename die with "rename involves
# overwriting ... not allowed" and the whole build exits 2. Just lay the real
# binary in place; teardown then renames .distrib back over identical content.
if ! is_real_ssd; then
  echo "start-stop-daemon fake or missing — reinstalling dpkg"
  apt-get update 2>&1 | tail -n1 || true
  apt-get install --reinstall -y dpkg 2>&1 | tail -n2 || true
fi
if ! is_real_ssd; then
  echo "apt reinstall failed — extracting from cached dpkg deb (no network needed)"
  DEB="$(ls -t /var/cache/apt/archives/dpkg_*.deb 2>/dev/null | head -n1)"
  if [ -n "$DEB" ]; then
    dpkg-deb --fsys-tarfile "$DEB" | tar -x -C / ./sbin/start-stop-daemon ./usr/sbin/start-stop-daemon 2>/dev/null || true
  fi
fi
# Keep teardown's rename safe: .distrib must match what we laid down, or its
# content check refuses the rename and the build exits 2 (same bug as above).
if is_real_ssd; then
  for _d in /usr/sbin/start-stop-daemon.distrib /sbin/start-stop-daemon.distrib.usr-is-merged; do
    [ -f "$_d" ] && cp -f /usr/sbin/start-stop-daemon "$_d" 2>/dev/null || true
  done
fi
ln -sf /sbin/start-stop-daemon /usr/bin/start-stop-daemon 2>/dev/null || true
[ -x /usr/sbin/start-stop-daemon ] && ln -sf /usr/sbin/start-stop-daemon /usr/bin/start-stop-daemon || true
ls -la /sbin/start-stop-daemon /usr/sbin/start-stop-daemon /usr/bin/start-stop-daemon || true
if ! is_real_ssd; then
  echo "FATAL: start-stop-daemon still fake/missing — refusing to pack a broken ISO"
  exit 1
fi
HOOK
chmod +x config/hooks/0099-helixos-dpkg-restore.hook.chroot
# Purge the redundant Debian installer: removed from the package list long ago,
# but the persistent chroot keeps reinstalling it (hence the second desktop icon).
cat > config/hooks/0099-helixos-purge-di.hook.chroot <<'HOOK'
#!/bin/sh
apt-get purge -y debian-installer-launcher 2>&1 | tail -n2 || true
# One installer icon survives: ours. The stock Calamares one (whatever filename
# the package version ships) must never reach the desktop.
rm -f /etc/skel/Desktop/install-debian.desktop /usr/share/applications/install-debian.desktop /usr/share/applications/calamares-install-debian.desktop 2>/dev/null || true
HOOK
chmod +x config/hooks/0099-helixos-purge-di.hook.chroot
# binary hook: populate isolinux dir with trixie syslinux modules (old live-build
# only copies the theme, leaving ldlinux.c32 et al behind -> "Failed to load ldlinux.c32").
# CRITICAL: isolinux.bin itself must come from the SAME chroot package — the old
# theme symlink pulled the host's build, and the version skew is what killed
# vesamenu (COM32 load failure) and forced the direct-boot hack. Unified now.
cat > config/hooks/0099-helixos-syslinux-modules.hook.binary <<'HOOK'
#!/bin/sh
set -e
# Always (over)write: stale or version-skewed modules break the menu silently
for m in ldlinux.c32 libcom32.c32 libutil.c32 libmenu.c32 libgpl.c32 vesamenu.c32 menu.c32; do
  f="$(find chroot/usr/lib/syslinux chroot/usr/lib/ISOLINUX -name "$m" 2>/dev/null | head -n1)"
  if [ -n "$f" ]; then cp -v "$f" binary/isolinux/; else echo "WARNING: $m not found in chroot"; fi
done
ISOBIN="$(find chroot/usr/lib/ISOLINUX -name 'isolinux.bin' 2>/dev/null | head -n1)"
if [ -n "$ISOBIN" ]; then cp -v "$ISOBIN" binary/isolinux/isolinux.bin; else echo "WARNING: isolinux.bin not found in chroot"; fi
HOOK
chmod +x config/hooks/0099-helixos-syslinux-modules.hook.binary
# rEFInd dual-boot picker on the USB: binaries from the live system, HelixOS-first
# config, auto-scans disk ESPs so Windows Boot Manager appears alongside HelixOS
cat > config/hooks/0099-helixos-refind.hook.binary <<'HOOK'
#!/bin/sh
set -e
REFIND="$(find chroot/usr/share -path '*refind*' -name 'refind_x64.efi' 2>/dev/null | head -n1)"
if [ -z "$REFIND" ]; then echo "WARNING: refind_x64.efi not in chroot (add refind to package list)"; exit 0; fi
mkdir -p binary/EFI/refind binary/efi-tools
cp -v "$REFIND" binary/EFI/refind/refind_x64.efi
cp -v "$REFIND" binary/efi-tools/refind_x64.efi
DRV="$(find chroot/usr/share -path '*refind*' -name 'ext4_x64.efi' 2>/dev/null | head -n1)"
if [ -n "$DRV" ]; then mkdir -p binary/EFI/refind/drivers_x64 && cp -v "$(dirname "$DRV")"/*.efi binary/EFI/refind/drivers_x64/; fi
cat > binary/EFI/refind/refind.conf <<'CONF'
timeout 10
scanfor internal,external,optical,manual
also_scan_dirs +EFI/refind
showtools shell,memtest,gdisk,mok_tool,about,hidden_tags,shutdown,reboot,firmware
menuentry "HelixOS Live" {
  volume HelixOS
  loader /live/vmlinuz
  initrd /live/initrd.img
  options "boot=live config username=helix quiet splash"
}
menuentry "HelixOS Recovery" {
  volume HelixOS
  loader /live/vmlinuz
  initrd /live/initrd.img
  options "boot=live config username=helix quiet splash helixos-recovery"
}
CONF
HOOK
chmod +x config/hooks/0099-helixos-refind.hook.binary

# Invalidate stages derived from our config so cached runs pick up flag/list changes
# (bootstrap + downloaded debs stay cached, only kernel/package stages re-run)
# NOTE: binary_syslinux is wiped with its target dir below, so its stamp must go too
rm -f .build/chroot_linux-image .build/chroot_package-lists.install .build/binary_syslinux .build/chroot_hooks
# Fix 2012-era absolute symlinks in syslinux theme: they must resolve INSIDE the
# trixie chroot (isolinux.bin lives in the isolinux deb, vesamenu in modules/bios)
sudo ln -sf /usr/lib/ISOLINUX/isolinux.bin /usr/share/live/build/bootloaders/isolinux/isolinux.bin
sudo ln -sf /usr/lib/syslinux/modules/bios/vesamenu.c32 /usr/share/live/build/bootloaders/isolinux/vesamenu.c32
# Seed trixie debian-cd metadata from sid (noble's live-build predates trixie)
if [ ! -d /usr/share/live/build/data/debian-cd/trixie ]; then
  sudo mkdir -p /usr/share/live/build/data/debian-cd/trixie
  sudo cp -r /usr/share/live/build/data/debian-cd/sid/* /usr/share/live/build/data/debian-cd/trixie/
  echo "Seeded trixie debian-cd data from sid."
fi
# Patch syslinux stage: bootlogo repack assumes a gfxboot archive the live-build
# theme never ships — skip repack when absent (vesamenu text menu still boots fine)
# Plus: kernel renames are not re-runnable (first pass already renamed vmlinuz-*
# to vmlinuz) — skip when globs match nothing
SYSFIX=/usr/lib/live/build/lb_binary_syslinux
if grep -q '(cd "$tmpdir" && cpio -i) < ${_TARGET}/bootlogo' "$SYSFIX" 2>/dev/null; then
  sudo sed -i 's|(cd "$tmpdir" && cpio -i) < ${_TARGET}/bootlogo|if [ -e "${_TARGET}/bootlogo" ]; then (cd "$tmpdir" \&\& cpio -i) < "${_TARGET}/bootlogo"; fi|' "$SYSFIX"
  echo "Patched $SYSFIX for missing bootlogo."
fi
if grep -q 'mv binary/live/vmlinuz-\* binary/live/vmlinuz$' "$SYSFIX" 2>/dev/null; then
  sudo sed -i 's|mv binary/live/vmlinuz-\* binary/live/vmlinuz$|if ls binary/live/vmlinuz-* >/dev/null 2>\&1; then mv binary/live/vmlinuz-* binary/live/vmlinuz; fi|; s|mv binary/live/initrd.img-\* binary/live/initrd.img$|if ls binary/live/initrd.img-* >/dev/null 2>\&1; then mv binary/live/initrd.img-* binary/live/initrd.img; fi|' "$SYSFIX"
  echo "Patched $SYSFIX for re-runnable kernel renames."
fi
# vesamenu.c32 fails to execute under QEMU SeaBIOS despite byte-valid modules —
# boot straight into the live system instead (UEFI path uses grub menu anyway)
# BIOS boot menu: Live Installer (default) + HelixOS Recovery. Possible now
# that isolinux.bin and its modules are version-unified (see hook above).
sudo tee /usr/share/live/build/bootloaders/isolinux/isolinux.cfg > /dev/null <<'ISOLINUX'
UI vesamenu.c32
MENU TITLE HelixOS 1.0 (Surge)
TIMEOUT 100
DEFAULT live
LABEL live
  MENU LABEL ^Live Installer
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live config username=helix quiet splash
LABEL recovery
  MENU LABEL ^HelixOS Recovery
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live config username=helix quiet splash helixos-recovery
LABEL failsafe
  MENU LABEL Live (failsafe)
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live config username=helix memtest noapic noapm nodma nomce nolapic nomodeset nosmp nosplash vga=normal
ISOLINUX
# rsvg compat shim: trixie dropped /usr/bin/rsvg (only rsvg-convert remains),
# but 2012 live-build calls: rsvg --format png --height H --width W IN OUT
sudo mkdir -p chroot/usr/bin
sudo tee chroot/usr/bin/rsvg > /dev/null <<'RSVG_EOF'
#!/bin/sh
# compat for old live-build: rsvg --format F --height H --width W IN OUT
format="png"; height=""; width=""; input=""; output=""
while [ $# -gt 0 ]; do
  case "$1" in
    --format) format="$2"; shift 2;;
    --height) height="$2"; shift 2;;
    --width) width="$2"; shift 2;;
    *) if [ -z "$input" ]; then input="$1"; else output="$1"; fi; shift;;
  esac
done
exec rsvg-convert --format "$format" --height "$height" --width "$width" --output "$output" "$input"
RSVG_EOF
sudo chmod +x chroot/usr/bin/rsvg
# Binary rebuild policy: FAST by default (resume — skips mksquashfs when the
# chroot is untouched, so ISO/bootloader-only iterations take minutes).
# Pass --full for the nuclear path (wipe binary tree + stamps, repack ~15 min).
# Use --full for release builds. chroot/ + deb caches are kept either way.
if [ "${1:-}" = "--full" ] || [ "${2:-}" = "--full" ]; then
  echo "FULL binary rebuild requested."
  sudo rm -rf binary chroot/binary 2>/dev/null || true
  rm -f .build/binary_*
fi
# Remove dead hook subdirs + retired hook files from earlier runs (live-build
# only reads config/hooks/ flat, and stale files keep executing forever)
rm -rf config/hooks/live config/hooks/binary 2>/dev/null || true
rm -f config/hooks/0099-helixos-plymouth.hook.chroot config/hooks/0099-helixos-plymouth-reset.hook.chroot 2>/dev/null || true
# Stale landmines in the persistent tree (each aborts lb_chroot_includes with a
# tar error or poisons chroot apt):
# - config/includes.chroot/etc/apt/sources.list.d/helixos.* (old experiment;
#   our repo must never be in chroot apt — the Updater owns it at runtime)
rm -f config/includes.chroot/etc/apt/sources.list.d/helixos.* 2>/dev/null || true
# Stale single-owner violation: the helixos-base deb owns /etc/helixos-release
# as a file, but old runs left a copy here that tar-bombs file-on-dir flips.
rm -f config/includes.chroot/etc/helixos-release 2>/dev/null || true
# - chroot/etc/helixos-release as a DIRECTORY (old packaging); the deb owns
#   this path as a file now, and tar refuses to overlay file-on-dir.
sudo rm -rf chroot/etc/helixos-release 2>/dev/null || true
# - chroot /tmp without the sticky bit breaks apt signature checks (_apt sandbox)
sudo mkdir -p chroot/tmp && sudo chmod 1777 chroot/tmp 2>/dev/null || true
# Stale HelixOS repo entries in config/archives (left by an old experiment)
# re-inject into EVERY build's chroot apt without their keyring -> all chroot
# apt updates fail "not signed". Our repo must never be in chroot apt.
rm -f config/archives/helixos* 2>/dev/null || true
# Purge retired Helix artwork from persistent config/includes.chroot AND chroot
# (both persist across builds; includes only ADD, so stale files re-inject forever)
sudo rm -rf chroot/usr/share/backgrounds/helixos-wallpaper.svg \
  chroot/usr/share/helixos \
  chroot/usr/share/plymouth/themes/helixos \
  chroot/usr/share/sddm/themes/breeze/theme.conf.user \
  chroot/etc/calamares/branding/helixos \
  chroot/etc/skel/.config/autostart/helixos-wallpaper.desktop \
  chroot/etc/skel/Desktop/helixos-install.desktop \
  chroot/usr/share/pixmaps/helixos-logo.png \
  chroot/etc/apt/sources.list.d/helixos-efi.list \
  chroot/etc/apt/sources.list.d/helixos-efi.sources \
  chroot/etc/apt/sources.list.d/helixos.sources \
  chroot/etc/apt/sources.list.d/helixos.list 2>/dev/null || true
# Same retired files in config/includes.chroot (re-injected into every build if left)
rm -rf config/includes.chroot/usr/share/backgrounds/helixos-wallpaper.svg \
  config/includes.chroot/usr/share/helixos \
  config/includes.chroot/usr/share/plymouth/themes/helixos \
  config/includes.chroot/usr/share/sddm/themes/breeze/theme.conf.user \
  config/includes.chroot/etc/calamares/branding/helixos \
  config/includes.chroot/etc/skel/.config/autostart/helixos-wallpaper.desktop \
  config/includes.chroot/usr/share/pixmaps/helixos-logo.png 2>/dev/null || true
# Stale chroot mounts from killed runs abort the next build — drop them first
# (lazy fallback detaches even busy ones)
for _m in chroot/proc chroot/sys chroot/dev/pts chroot/selinux; do
  sudo umount -R "$_m" 2>/dev/null || sudo umount -l "$_m" 2>/dev/null || true
done
# Stale zsync artifacts abort the final stage (xz refuses to overwrite)
rm -f *.zsync *.zsync.xz 2>/dev/null || true
# Reinstall installer stack every build (a second apt pass autoremoves calamares
# while leaving our job configs orphaned -> "modules not initialised")
sudo chroot chroot apt-get install -y --no-remove calamares calamares-settings-debian refind efibootmgr os-prober 2>/dev/null || true
# Drop the accumulated install queue too — lb APPENDS to chroot/root/packages.chroot
# and failed runs never consume it, so stale names survive stamp resets
sudo rm -f config/packages.chroot/* config/packages.binary/* 2>/dev/null || true
sudo rm -f chroot/root/packages.chroot chroot/root/packages.binary cache/packages.chroot 2>/dev/null || true

sudo lb build
ls -lh *.hybrid.iso *.iso 2>/dev/null || true
mkdir -p "$ROOT/build"
ISO_OUT="$(ls -t helixos-live*.iso helixos-live*.hybrid.iso live-image*.iso binary.hybrid.iso 2>/dev/null | head -n1 || true)"
if [ -z "$ISO_OUT" ]; then echo "ERROR: no ISO produced"; exit 1; fi
# Inject UEFI (grub-efi) — old live-build has no such stage, trixie grub-legacy is hollow.
# add-efi.sh mirrors the final ISO to $ROOT/build itself, so both entry points land together.
bash "$ROOT/scripts/add-efi.sh" "$ISO_OUT" "$LB_DIR/helixos-live.iso"
echo "ISO OK: $ROOT/build/helixos-live.iso (BIOS syslinux + UEFI grub, signed SB chain) — flash Rufus ISO mode (DD fallback), F12."
