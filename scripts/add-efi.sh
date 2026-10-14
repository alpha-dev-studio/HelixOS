#!/usr/bin/env bash
set -euo pipefail
# Adds UEFI boot (grub-efi) to a BIOS-only iso-hybrid.
# Noble's live-build has no grub-efi stage, and trixie grub-legacy is hollow,
# so: proven syslinux BIOS path from live-build + hand-injected EFI partition.
# Usage: ./scripts/add-efi.sh [input.iso] [output.iso]
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IN="${1:-$HOME/helixos-iso/binary.hybrid.iso}"
OUT="${2:-$HOME/helixos-iso/helixos-live.iso}"
GRUBCFG="$ROOT/configs/grub/grub.cfg"

sudo apt-get update
sudo apt-get install -y grub-efi-amd64-bin dosfstools mtools xorriso

WORK="$(mktemp -d)"
EFIDIR="$WORK/efi"
mkdir -p "$EFIDIR/EFI/BOOT"
# Early config (embedded): find ISO by volume id, load themed grub.cfg
cat > "$WORK/early.cfg" <<'EOF'
search --set=root --label HelixOS
set prefix=($root)/boot/grub
configfile /boot/grub/grub.cfg
EOF
# Secure Boot chain (proper fix): Debian-signed shim + grub. Microsoft trusts the
# shim, shim trusts Debian grub, grub trusts the Debian-signed kernel — Secure
# Boot stays ON. Must come from TRIXIE (host Ubuntu-signed binaries carry the
# wrong keys and grub would reject our Debian kernel), so download via chroot apt.
SIGDIR="$HOME/helixos-iso/signed-efi"
CHROOT="$HOME/helixos-iso/chroot"
mkdir -p "$SIGDIR"
# Reuse previously downloaded signed debs — skip chroot apt entirely when present
if ls "$SIGDIR"/shim-signed_* >/dev/null 2>&1 && ls "$SIGDIR"/grub-efi-amd64-signed_* >/dev/null 2>&1; then
  echo "Signed debs cached in $SIGDIR — skipping download."
else
if [ -d "$CHROOT/etc" ]; then
  sudo mount -t proc none "$CHROOT/proc" 2>/dev/null || true
  sudo mount --rbind /sys "$CHROOT/sys" 2>/dev/null || true
  sudo mount --rbind /dev "$CHROOT/dev" 2>/dev/null || true
  sudo cp /etc/resolv.conf "$CHROOT/etc/resolv.conf" 2>/dev/null || true
  echo "deb https://deb.debian.org/debian trixie main contrib non-free non-free-firmware" | sudo tee "$CHROOT/etc/apt/sources.list.d/helixos-efi.list" > /dev/null
  sudo rm -f "$CHROOT/etc/apt/sources.list.d/helixos-efi.sources" /etc/apt/sources.list.d/helixos-efi.sources 2>/dev/null || true
  APTLOG="$WORK/chroot-apt.log"
  sudo chroot "$CHROOT" apt-get update > "$APTLOG" 2>&1 || { echo "--- chroot apt update failed ---"; tail -n 8 "$APTLOG"; }
  # apt-get download inside chroot must run with cwd=/tmp (host $SIGDIR is invisible
  # inside the chroot, so the old '(cd $SIGDIR && chroot ... download)' never landed)
  sudo chroot "$CHROOT" sh -c "cd /tmp && apt-get download shim-signed grub-efi-amd64-signed" >> "$APTLOG" 2>&1 || { echo "--- chroot download failed ---"; tail -n 12 "$APTLOG"; }
  sudo cp -f "$CHROOT"/tmp/shim-signed*.deb "$CHROOT"/tmp/grub-efi-amd64-signed*.deb "$SIGDIR/" 2>/dev/null || echo "--- copy debs out of chroot failed ---"
  sudo rm -f "$CHROOT"/tmp/shim-signed*.deb "$CHROOT"/tmp/grub-efi-amd64-signed*.deb 2>/dev/null || true
  sudo chown "$(id -u):$(id -g)" "$SIGDIR"/*.deb 2>/dev/null || true
  # One-shot source must not ride into the image (it duplicates sources.list -> apt warnings)
  sudo rm -f "$CHROOT/etc/apt/sources.list.d/helixos-efi.list" "$CHROOT/etc/apt/sources.list.d/helixos-efi.sources" 2>/dev/null || true
  sudo umount -R "$CHROOT/proc" 2>/dev/null || true
  sudo umount -R "$CHROOT/sys" 2>/dev/null || true
  sudo umount -R "$CHROOT/dev" 2>/dev/null || true
fi
fi
if ls "$SIGDIR"/shim-signed_* >/dev/null 2>&1 && ls "$SIGDIR"/grub-efi-amd64-signed_* >/dev/null 2>&1; then
  rm -rf "$SIGDIR/extract" && mkdir -p "$SIGDIR/extract"
  dpkg-deb -x "$SIGDIR"/shim-signed_*.deb "$SIGDIR/extract" 2>/dev/null || dpkg-deb -x $(ls -t "$SIGDIR"/shim-signed_*.deb | head -n1) "$SIGDIR/extract"
  dpkg-deb -x $(ls -t "$SIGDIR"/grub-efi-amd64-signed_*.deb | head -n1) "$SIGDIR/extract"
  # Locate binaries dynamically — never silently ship an ESP without grubx64.efi
  # (shim boots, then fails with "failed to open \EFI\BOOT\grubx64.efi").
  SHIM_BIN="$(find "$SIGDIR/extract" -name 'shimx64.efi*' | head -n1)"
  GRUB_BIN="$(find "$SIGDIR/extract" -name 'grubx64.efi*' | head -n1)"
  MOK_BIN="$(find "$SIGDIR/extract" -name 'mmx64.efi' | head -n1)"
  [ -n "$SHIM_BIN" ] || { echo "ERROR: no shim binary in signed debs — inspect with: find $SIGDIR/extract -name '*.efi'"; exit 1; }
  [ -n "$GRUB_BIN" ] || { echo "ERROR: no grub binary in signed debs — inspect with: find $SIGDIR/extract -name '*.efi'"; exit 1; }
  cp -f "$SHIM_BIN" "$EFIDIR/EFI/BOOT/BOOTX64.EFI"
  cp -f "$GRUB_BIN" "$EFIDIR/EFI/BOOT/grubx64.efi"
  [ -n "$MOK_BIN" ] && cp -f "$MOK_BIN" "$EFIDIR/EFI/BOOT/" || true
  echo "Secure Boot chain: Debian-signed shim+grub (SB can stay ON)."
else
  echo "WARNING: signed debs unavailable — falling back to self-built BOOTX64.EFI (needs Secure Boot OFF)."
  grub-mkstandalone -O x86_64-efi -o "$EFIDIR/EFI/BOOT/BOOTX64.EFI" \
    --modules="part_gpt part_msdos fat iso9660 normal boot linux configfile loopback chain search search_fs_uuid search_fs_file search_label gfxterm gfxterm_background png jpeg test all_video efi_gop efi_uga echo font" \
    "/boot/grub/grub.cfg=$WORK/early.cfg"
fi
# Fallback copy beside the binary (auto-discovered on some firmwares)
cp "$WORK/early.cfg" "$EFIDIR/EFI/BOOT/grub.cfg"
# FAT image carrying the ESP
dd if=/dev/zero of="$WORK/efi.img" bs=1M count=8 status=none
mkfs.vfat "$WORK/efi.img" > /dev/null
mcopy -s -i "$WORK/efi.img" "$EFIDIR/EFI" ::/
# Rebuild ISO from the live-build binary tree with BIOS (isolinux) + EFI entries.
# (xorriso dialog mode refused the ops; the documented xorrisofs pattern works.)
LB_DIR="$HOME/helixos-iso"
if [ ! -d "$LB_DIR/binary/live" ]; then
  echo "ERROR: $LB_DIR/binary/live missing — run ./scripts/make-iso.sh first (need IN=$IN tree)"
  exit 1
fi
ISO_MBR=/usr/lib/ISOLINUX/isohdpfx.bin
[ -e "$ISO_MBR" ] || ISO_MBR=/usr/lib/syslinux/mbr/isohdpfx.bin
# Also seed the ESP tree into the ISO filesystem (Rufus ISO mode needs /EFI/BOOT
# visible as files; DD mode works from the appended partition alone)
sudo mkdir -p "$LB_DIR/binary/EFI/BOOT"
sudo cp -f "$EFIDIR/EFI/BOOT/BOOTX64.EFI" "$LB_DIR/binary/EFI/BOOT/BOOTX64.EFI"
sudo cp -f "$EFIDIR/EFI/BOOT/grubx64.efi" "$LB_DIR/binary/EFI/BOOT/grubx64.efi" 2>/dev/null || true
sudo cp -f "$EFIDIR/EFI/BOOT/mmx64.efi" "$LB_DIR/binary/EFI/BOOT/mmx64.efi" 2>/dev/null || true
sudo cp -f "$WORK/early.cfg" "$LB_DIR/binary/EFI/BOOT/grub.cfg"
sudo chown -R "$(id -u):$(id -g)" "$LB_DIR/binary/EFI" 2>/dev/null || true
rm -f "$OUT" 2>/dev/null || sudo rm -f "$OUT"
(cd "$LB_DIR/binary" && xorriso -as mkisofs \
  -o "$OUT" \
  -V HelixOS \
  -J -R -l \
  -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e --interval:appended_partition_2:all:: -no-emul-boot \
  -append_partition 2 0xef "$WORK/efi.img" \
  -isohybrid-mbr "$ISO_MBR" \
  -partition_offset 16 \
  .)
isohybrid --uefi "$OUT"
sudo chown "$(id -u):$(id -g)" "$OUT" 2>/dev/null || true
ls -lh "$OUT"
# Mirror into the repo so standalone runs land in the same place as make-iso.sh builds
mkdir -p "$ROOT/build"
cp -vf "$OUT" "$ROOT/build/helixos-live.iso" 2>/dev/null || sudo cp -vf "$OUT" "$ROOT/build/helixos-live.iso"
rm -rf "$WORK"
echo "EFI OK: $OUT (El Torito BIOS + EFI, isohybrid --uefi)"
echo "Mirrored: $ROOT/build/helixos-live.iso"
