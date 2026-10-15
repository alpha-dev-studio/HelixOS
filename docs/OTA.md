# HelixOS OTA design — all three tiers

## Tier 1 — packaged updates (LIVE)
Everything including the kernel ships as versioned debs through
`https://alpha-dev-studio.github.io/HelixOS` (signed, `testing` →
`stable` promotion). Custom kernel: `scripts/build-kernel.sh` stamps
`+helixosN` above stock versions so apt prefers ours. Clients need no
changes — Discover + `unattended-upgrades` already point at the repo.

## Tier 2 — Debian upstream (LIVE)
`trixie` security + point releases flow via `unattended-upgrades`
(auto-enabled in the image: `20helixos-auto-upgrades`). We inherit the
Debian security team free. Pin codenames per HelixOS major (Surge=trixie,
Arc=forky); major jumps go through a tested `helixos-upgrade` meta-package,
never a surprise.

## Tier 3 — A/B image updates (FOUNDATION LAID, NOT ACTIVE)
`rauc` ships in the image but does nothing yet — on purpose. Activation needs:

1. **Slot layout in the installer:** two root partitions (A/B, ~8GB each) +
   one ESP + data partition. Calamares partition module changes + the
   `helixos-refind-install` job extended to register both slots.
2. **Boot counting:** GRUB `bootcount`/`boot_success` flags so a failed boot
   falls back to the previous slot automatically.
3. **Bundle server:** `rauc` bundles (`.raucb`, signed with the repo GPG key)
   published next to the apt repo; clients poll + install to the idle slot.
4. **Fleet gate:** build this when a lab/refurbisher with 10+ machines asks —
   single-user systems gain little over Tier 1+2, and every slot doubles disk cost.

Status: Tier 1 + 2 operational. Tier 3 activates on first fleet demand.

## Rollback (LIVE, needs btrfs root)
Every apt run takes a snapper pre/post pair (`80helixos-snapshots`), keeping
the last 10. A broken update = boot the live USB, mount root at /mnt,
`btrfs subvolume list /mnt` to find the pre-upgrade snapshot id,
`btrfs subvolume set-default <id> /mnt`, reboot — system back in minutes.
(grub-btrfs would put snapshots in the GRUB menu directly, but it is not a
Debian package — vendoring + testing its upstream script is the follow-up.)
Requirement: root on btrfs — pick it in Calamares manual partitioning until
it becomes the default layout. ext4 installs get no snapshots (apt still
works, just without a safety net).

## Release jumps Surge->Arc->Flux (ORCHESTRATOR SHIPPED, TARGETS LATER)
`helixos-upgrade` (installed with the OS): snapshots first, swaps Debian +
HelixOS suites to the next codename, staged `full-upgrade`, pairs the
snapshot, reboots. /home is never touched; any failure restores sources and
points at the GRUB snapshot. Running it before the target suite exists
prints the path status and exits — safe to poke. Arc's suite + packages land
when forky stabilizes; the machinery is already on every machine.
