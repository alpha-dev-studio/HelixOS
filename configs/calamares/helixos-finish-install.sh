#!/bin/sh
# HelixOS post-install cleanup (runs in the INSTALLED system at end of setup).
# The live user helix gets copied to disk by unpackfs — remove it once a real
# user exists, so login shows exactly one account. Never fails the install.
LOG=/tmp/helixos-finish-install.log
{
  echo "=== helixos-finish-install $(date -u) ==="
  if id helix >/dev/null 2>&1; then
    OTHERS="$(awk -F: '$3 >= 1000 && $3 < 60000 && $1 != "helix" && $1 != "nobody" {print $1}' /etc/passwd)"
    if [ -n "$OTHERS" ]; then
      echo "real user(s) present ($OTHERS) — removing live user helix"
      userdel -r helix 2>&1 || echo "userdel helix failed"
    else
      echo "helix is the only user — keeping it as the system owner"
    fi
  else
    echo "no helix user — nothing to do"
  fi
  # Recovery mode is ISO-media only: the autostart wrapper must not follow the
  # install onto disk (installed bootloaders never pass the flag anyway, but
  # dead weight with root hooks is how ghosts are born). The rescue tool itself
  # stays — harmless off-USB, refuses non-live runs by design.
  rm -f /etc/xdg/autostart/helixos-recovery.desktop /usr/bin/helixos-recovery-autostart
  echo "recovery autostart stripped from installed system"
} >> "$LOG" 2>&1
exit 0
