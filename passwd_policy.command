#!/bin/bash

set -euo pipefail
exec >/dev/null 2>&1

MAXPWAGE_DAYS=90
MINPWAGE_DAYS=1
PW_HISTORY=3
LOCK_THRESH=5
LOCK_DURATION_MIN=10
LOCK_WINDOW_MIN=10

fail() {
  exit 1
}

ensure_prereqs() {
  command -v pwpolicy >/dev/null 2>&1 || fail
}

require_root() {
  [[ "$EUID" -eq 0 ]] || fail
}

apply_policy() {
  local max_minutes min_minutes
  max_minutes=$((MAXPWAGE_DAYS * 24 * 60))
  min_minutes=$((MINPWAGE_DAYS * 24 * 60))

  pwpolicy -n /Local/Default -setglobalpolicy \
    "maxMinutesUntilChangePassword=$max_minutes" \
    "minMinutesUntilChangePassword=$min_minutes" \
    "usingHistory=1" \
    "passwordHistoryDepth=$PW_HISTORY" \
    "maxFailedLoginAttempts=$LOCK_THRESH" \
    "minutesUntilFailedLoginReset=$LOCK_WINDOW_MIN" \
    "minMinutesUntilFailedLoginReset=$LOCK_DURATION_MIN"
}

main() {
  ensure_prereqs
  require_root
  apply_policy
}

main "$@"
