#!/usr/bin/env bash
set -euo pipefail
# Tier 1 OTA: build a HelixOS-suffixed kernel deb. The +helixos1 suffix versions
# ABOVE stock Debian, so every machine upgrades to it via the normal channel.
# Usage: ./scripts/build-kernel.sh [version]   (default: 6.12.107)
# Needs: 8GB+ free in ~/helixos-build, several hours on 2 cores first run.
# Output: linux-image-*.deb in ~/helixos-build/, then publish via repo flow.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KVER="${1:-6.12.107}"
BUILD="$HOME/helixos-build/kernel-$KVER"
RELEASE="${HELIXOS_RELEASE:-1}"

sudo apt-get update
sudo apt-get install -y build-essential bc flex bison libssl-dev libelf-dev \
  debhelper rsync cpio kmod pahole dwarves 2>/dev/null || true

mkdir -p "$BUILD"
cd "$BUILD"
if [ ! -d "linux-$KVER" ]; then
  wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KVER.tar.xz"
  tar xf "linux-$KVER.tar.xz"
fi
cd "linux-$KVER"
# Base config: Debian's own amd64 config if available, else defconfig
if [ -f "/boot/config-$(uname -r)" ]; then
  cp "/boot/config-$(uname -r)" .config
  scripts/config --set-str LOCALVERSION "-helixos$RELEASE" --enable IKCONFIG_PROC || true
  make olddefconfig
else
  make defconfig
  scripts/config --set-str LOCALVERSION "-helixos$RELEASE" || true
fi
# Parallel build, Debian-style binary debs
make -j"$(nproc)" bindeb-pkg
echo "Kernel debs ready above $BUILD/linux-$KVER — copy the linux-image deb to packages/ and publish."
ls -lh ../*.deb 2>/dev/null || true
