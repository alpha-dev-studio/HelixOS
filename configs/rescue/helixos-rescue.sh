#!/usr/bin/env bash
set -euo pipefail
# helixos-rescue — repair or update an INSTALLED HelixOS from the live USB.
# (The BIOS-update fantasy, minus the terror: pick a job, it operates on the
# installed system, never on the live session itself.)
# Jobs: update packages, reinstall bootloader (+rEFInd), roll back to a
# snapshot, reset a forgotten user password.
MNT=/mnt/helix-target

say() { echo "==> $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || exec pkexec "$0" "$@"

# Refuse to run against the live system itself (override only if you mean it).
if [ ! -d /run/live/medium ] && [ "${1:-}" != "--i-know-what-im-doing" ]; then
  die "no live session detected — this tool repairs installed systems from USB"
fi

cleanup() {
  umount -R "$MNT/boot/efi" 2>/dev/null || true
  umount -R "$MNT/dev" 2>/dev/null || true
  umount -R "$MNT/sys" 2>/dev/null || true
  umount -R "$MNT/proc" 2>/dev/null || true
  umount -R "$MNT" 2>/dev/null || true
}
trap cleanup EXIT
mkdir -p "$MNT"

# --- find installed HelixOS roots (skip the live USB itself) ---
LIVE_SRC="$(findmnt -no SOURCE /run/live/medium 2>/dev/null || true)"
LIVE_DISK="$(lsblk -no PKNAME "$LIVE_SRC" 2>/dev/null || true)"
CANDS=()
say "Scanning disks (live USB is $LIVE_SRC, skipped)..."
for dev in /dev/sd*[0-9] /dev/nvme*n*p* /dev/vd*[0-9] /dev/mmcblk*p* /dev/nbd*p*; do
  [ -b "$dev" ] || continue
  case "$dev" in /dev/"$LIVE_DISK"*) [ -n "$LIVE_DISK" ] && continue ;; esac
  FSTYPE="$(blkid -o value -s TYPE "$dev" 2>/dev/null || true)"
  case "$FSTYPE" in ext4|btrfs|xfs) ;; *) continue ;; esac
  if mount -o ro "$dev" "$MNT" 2>/dev/null; then
    if [ -f "$MNT/etc/helixos-release" ]; then
      VER="$(head -n1 "$MNT/etc/helixos-release" 2>/dev/null)"
      CANDS+=("$dev|$VER")
      echo "  found: $dev ($VER)"
    fi
    umount "$MNT" 2>/dev/null || true
  fi
done
[ "${#CANDS[@]}" -gt 0 ] || die "no installed HelixOS found (is the disk visible? try Disks app)"
TARGET="${CANDS[0]%%|*}"
if [ "${#CANDS[@]}" -gt 1 ]; then
  echo "Multiple installs found:"
  i=1; for c in "${CANDS[@]}"; do echo "  $i) $c"; i=$((i+1)); done
  read -rp "Pick one [1]: " pick
  pick="${pick:-1}"
  TARGET="$(echo "${CANDS[$((pick-1))]}" | cut -d'|' -f1)"
fi

# --- mount target (+ ESP + binds + DNS) ---
say "Mounting $TARGET ..."
mount "$TARGET" "$MNT" || die "cannot mount $TARGET"
DISK="/dev/$(lsblk -no PKNAME "$TARGET" 2>/dev/null || true)"
ESP=""
if [ -n "$DISK" ] && [ -b "$DISK" ]; then
  for part in ${DISK}* ${DISK}p*; do
    [ -b "$part" ] || continue
    [ "$part" = "$TARGET" ] && continue
    PTYPE="$(blkid -o value -s TYPE "$part" 2>/dev/null || true)"
    if [ "$PTYPE" = "vfat" ]; then ESP="$part"; break; fi
  done
fi
if [ -n "$ESP" ]; then
  mkdir -p "$MNT/boot/efi"
  mount "$ESP" "$MNT/boot/efi" 2>/dev/null && say "ESP $ESP mounted" || say "ESP mount skipped"
fi
mount -t proc none "$MNT/proc" 2>/dev/null || true
mount --rbind /sys "$MNT/sys" 2>/dev/null || true
mount --rbind /dev "$MNT/dev" 2>/dev/null || true
cp /etc/resolv.conf "$MNT/etc/resolv.conf" 2>/dev/null || true

# --- menu ---
while true; do
  echo ""
  echo "HelixOS Rescue — target: $TARGET"
  echo "  1) Update system (apt update + full-upgrade in target)"
  echo "  2) Repair bootloader (GRUB UEFI/BIOS + rEFInd)"
  echo "  3) Roll back to snapshot (btrfs only)"
  echo "  4) Reset a user password"
  echo "  5) Quit (unmounts cleanly)"
  read -rp "Choice [1]: " c
  case "${c:-1}" in
    1)
      say "Updating target..."
      chroot "$MNT" apt-get update
      chroot "$MNT" apt-get full-upgrade -y
      say "Update done."
      ;;
    2)
      say "Repairing bootloader..."
      if [ -d /sys/firmware/efi ]; then
        chroot "$MNT" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=HelixOS --recheck 2>&1 | tail -n2 || true
      else
        say "Legacy boot — installing to $DISK"
        chroot "$MNT" grub-install --target=i386-pc "$DISK" 2>&1 | tail -n2 || true
      fi
      chroot "$MNT" update-grub 2>&1 | tail -n2 || true
      refind-install --root "$MNT" --yes 2>&1 | tail -n2 || echo "(rEFInd skipped)"
      say "Bootloader done."
      ;;
    3)
      if ! findmnt -no FSTYPE "$MNT" 2>/dev/null | grep -q btrfs; then
        echo "Target is not btrfs — snapshots unavailable (ext4 has no rollback)."
        continue
      fi
      say "Snapshots on target:"
      btrfs subvolume list "$MNT" 2>/dev/null | grep -i snap | head -n 20 || echo "(none found)"
      read -rp "Snapshot subvolume id to roll back to (blank = cancel): " sid
      if [ -n "$sid" ]; then
        btrfs subvolume set-default "$sid" "$MNT" && say "Will boot snapshot $sid next start." || echo "set-default failed"
      fi
      ;;
    4)
      say "Users on target:"
      chroot "$MNT" awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd
      read -rp "Username: " u
      read -rsp "New password: " p1; echo ""
      read -rsp "Repeat: " p2; echo ""
      if [ "$p1" = "$p2" ] && [ -n "$p1" ]; then
        echo "$u:$p1" | chroot "$MNT" chpasswd && say "Password set for $u."
      else
        echo "Passwords differ or empty — nothing changed."
      fi
      ;;
    5) say "Unmounted. Pull the USB only after shutdown."; break ;;
    *) echo "Pick 1-5." ;;
  esac
done
