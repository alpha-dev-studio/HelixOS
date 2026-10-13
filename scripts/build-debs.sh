#!/usr/bin/env bash
set -euo pipefail
# Builds HelixOS .debs (OTA payloads) — needs: sudo apt install build-essential debhelper
# Usage: ./scripts/build-debs.sh  ->  packages/*.deb
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
sudo apt-get update
sudo apt-get install -y build-essential debhelper
# Windows mounts force +x on everything, which breaks dh_install.
# Build on native ext4 tmp, then copy .debs back.
TMPBASE="$(mktemp -d /tmp/helixos-debs-XXXX)"
for PKGDIR in "$ROOT"/packages/*/; do
  [ -f "$PKGDIR/debian/control" ] || continue
  PKG="$(basename "$PKGDIR")"
  echo "=== building $PKG ==="
  # drop stale in-tree build artifacts from previous failed runs
  rm -rf "$PKGDIR/debian/.debhelper" "$PKGDIR/debian/$PKG" "$PKGDIR/debian/debhelper-build-stamp" "$PKGDIR/.debhelper" 2>/dev/null || true
  WORK="$TMPBASE/$PKG"
  rm -rf "$WORK"
  cp -a "$PKGDIR" "$WORK"
  chmod +x "$WORK/debian/rules"
  chmod -x "$WORK/debian/install" "$WORK/debian/control" "$WORK/debian/changelog" 2>/dev/null || true
  rm -rf "$WORK/debian/.debhelper" "$WORK/debian/$PKG" "$WORK/debian/debhelper-build-stamp" 2>/dev/null || true
  (cd "$WORK" && dpkg-buildpackage -us -uc -b)
done
cp -vf "$TMPBASE"/*.deb "$ROOT/packages/" 2>/dev/null || true
rm -rf "$TMPBASE"
echo "Debs land in $ROOT/packages/ — upload to the apt repo (testing first)."
