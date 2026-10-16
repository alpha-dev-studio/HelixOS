# How HelixOS works

One pipeline, end to end: source tree → bootable signed ISO → installed
system that updates itself. Everything below is what the scripts and
packages actually do. Read this before changing any of them.

## Big picture

```
source tree  --build-debs-->  packages/*.deb
      |
      +--make-iso.sh-->  ~/helixos-iso (live-build tree)
      |                      + chroot (Debian trixie + our list)
      |                      + hooks (convergence, identity, rescue)
      |                      + local debs baked in late
      |                      + squashfs + ISO (BIOS syslinux)
      +--add-efi.sh--->  signed UEFI injection, isohybrid
      |
      = build/helixos-live.iso  -->  Rufus  -->  live USB
                                         +--> Try HelixOS
                                         +--> Install (Calamares)
                                               +--> disk system
                                                     +--> Helix Updater (OTA)
```

Builds run in WSL Ubuntu. The source tree stays on the Windows side;
all building happens on ext4 (`~/helixos-iso`) because Windows mounts
break Debian packaging permissions.

## scripts/setup-wsl.sh
One-time host setup: compilers, debootstrap, xorriso, grub tooling,
qemu, cpio, git. Run once per fresh WSL install.

## scripts/build-debs.sh (local-only, not committed)
Builds every package in `packages/*/` into `packages/*.deb`.
Copies each package to a native ext4 temp dir first: Windows mounts
force `+x` on every file, which breaks `dh_install`, so the build
never runs on the mount directly. Needs `build-essential`, `debhelper`.

## scripts/make-iso.sh [--full | --clean]
The whole OS build. Plain run resumes the tree in `~/helixos-iso`
(fast, skips re-squashing when the chroot is unchanged). `--full`
repacks the binary tree (needed after any chroot content change).
`--clean` wipes the tree and starts from zero (hours).

1. Installs live-build + bootloader + squashfs tooling on the host.
2. Patches the host's live-build for trixie: per-component
   `Contents-*` paths, hollow grub-legacy names → `grub-pc`,
   and the `start-stop-daemon` teardown (see the teardown trap below).
3. `lb config`: Debian trixie, systemd, amd64, iso-hybrid,
   syslinux BIOS bootloader, live Debian installer, HelixOS volume
   identity, quiet splash boot line.
4. Writes the package list (`config/package-lists/helixos.list.chroot`):
   labwc + qt6 stack + Helix shell deps, utilities (firefox, kate,
   okular, ark, spectacle, dolphin + konsole as fallbacks), firmware
   for every Debian-supported device, GRUB + shim for offline
   installs, power profiles, flatpak, fprintd, snapper + btrfs,
   unattended-upgrades. No Plasma: the shell is ours.
5. Writes `config/includes.chroot/` (files baked into every image):
   Helix release file, hostname/hosts, SDDM breeze theme pin,
   auto-upgrade + snapshot apt hooks, snapper root config,
   installer + rescue launchers, Helix recovery autostart wrapper,
   Calamares job configs (rEFInd + finish-install sequencing).
6. Registers chroot hooks (`config/hooks/*.hook.chroot`), executed
   inside the image during build, in order:
   - Calamares jobs sequenced after the bootloader step
   - live user `helix` (empty password, passwordless sudo)
   - local helixos debs installed late (postinst converges the image)
   - `start-stop-daemon` restored to the real binary (ENFORCED: the
     build dies rather than ship the fake, which used to break every
     Calamares target install with apt code 100)
   - redundant Debian installer launcher purged (one installer icon)
   - syslinux modules populated for the trixie bootloader
7. Pre-build cleanup: dead hook dirs, retired artwork, stale chroot
   config landmines (old repo entries, file-vs-dir collisions), stale
   mounts, zsync leftovers; installer stack reinstalled every build.
8. `lb build`, then picks the freshest ISO and hands it to add-efi.sh.
9. Teardown trap (live-build bug #2122623, documented in-script): on
   usrmerged trixie the divert records must be left for live-build's
   own remove stage — early removal aborts the build with exit 2.
   Our hook lays the real binary down and lets teardown do its rename.

## scripts/add-efi.sh [input.iso] [output.iso]
Old live-build emits BIOS-only images, so UEFI is hand-injected:
reuses cached Debian-signed `shim` + `grub` debs (downloaded once via
a chroot apt), embeds an early config that finds the ISO by volume id,
rebuilds with xorriso, runs `isohybrid --uefi`, mirrors the result to
`build/helixos-live.iso`. Outcome: one image, BIOS syslinux menu +
UEFI GRUB + rEFInd picker, Secure Boot stays on.

## scripts/publish-pages.sh [testing|stable] (local-only, not committed)
Turns built debs into a signed apt repo under `build/apt-repo`
(`dists/trixie/...`), signs Release with `$GPGKEY`, ready to push to
the `repo` branch behind Pages. Clients: the HelixOS Updater only —
apt/Discover stay Debian-only by architecture rule.

## scripts/build-kernel.sh [version]
Tier 1 escape hatch: builds a `+helixosN`-suffixed kernel deb that
versions above stock Debian, so machines adopt it through the normal
channel. Hours on 2 cores; stock kernel until someone needs a fork.

## packages/helixos-base (OTA channel + identity)
Ships the release file, keyring, the HelixOS Updater app + its
passwordless polkit rule, and postinst convergence (live-user
cleanup, single installer icon, legacy repo purge, Debian-only apt).
The Updater owns the HelixOS repo: enables it per transaction, hides
it after, flags reboots. Version bumps are the OTA mechanism.

## packages/helixos-upgrade (major jumps)
Surge→Arc→Flux orchestrator: snapshots first, swaps suites, staged
full-upgrade, pairs the snapshot, reboots. Safe to poke before the
target suite exists.

## packages/helix-shell (the desktop)
QML shell (lock, desktop, taskbar, Start, flyouts, 7 apps, OOBE),
`helix-session` launcher (labwc + env + socket wait), SDDM session
file, minimal labwc theme, backlight udev rule, and the Helix bridge
(PyQt6 injector: launching, power, wifi, battery, volume,
brightness, processes, files, resolutions, update checks).

## Boot flow
BIOS → syslinux menu. UEFI → signed shim → signed GRUB → menu:
Live Installer (default), HelixOS Recovery (`helixos-recovery` flag
→ rescue tool autostart), rEFInd picker. Microsoft trusts the shim,
the shim trusts Debian grub, grub trusts the Debian kernel.

## Live session → install
SDDM greets, the Helix session starts (single session by design —
the old second-session-blank-desktop bug can't recur). Live user
`helix`, empty password. Install HelixOS runs Calamares: rEFInd job
registers the bootloader, finish-install strips live-only pieces
(recovery autostart, live user handling) and converges the target.

## Updates on installed systems
Debian security + point releases arrive automatically. HelixOS
packages (including the shell) arrive versioned through the signed
repo, applied by the HelixOS Updater. Every apt run is wrapped in a
snapper pre/post snapshot pair (btrfs root): a broken update =
reboot to the pre-upgrade snapshot. Rollback procedure: boot live
USB, mount root, `btrfs subvolume set-default <pre-id>`, reboot.

## Artifact map
- `~/helixos-iso/` — live-build tree (disposable; `--clean` rebuilds)
- `build/helixos-live.iso` — the ship artifact (flash with Rufus)
- `packages/*.deb` — built OTA payloads (gitignored output)
- `build/apt-repo/` — signed repo staging (pushed to `repo` branch)
