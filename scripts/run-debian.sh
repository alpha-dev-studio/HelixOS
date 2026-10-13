#!/usr/bin/env bash
set -euo pipefail
# Boot HelixOS (Debian trixie) rootfs in QEMU from ext4 image (LABEL=helixos)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Prefer native Linux build dir (ext4), fallback to repo build copy
if [ -f "$HOME/helixos-build/vmlinuz-trixie" ]; then BUILD="$HOME/helixos-build"; else BUILD="$ROOT/build"; fi
LD_IMG="helixos-trixie.ext4"
exec qemu-system-x86_64 \
  -kernel "$BUILD/vmlinuz-trixie" \
  -initrd "$BUILD/initrd-trixie" \
  -append "root=LABEL=helixos rw console=ttyS0 systemd.unit=multi-user.target" \
  -drive file="$BUILD/$LD_IMG",format=raw,if=virtio \
  -nographic -m 1024 -smp 1 \
  -net nic -net user,hostfwd=tcp::2222-:22
