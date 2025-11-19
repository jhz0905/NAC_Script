#!/bin/bash

set -euo pipefail

DEBUG="${DEBUG:-0}"

if [[ "$DEBUG" -ne 1 ]]; then
  exec >/dev/null 2>&1
fi

log() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo "[deactivate_auto_login] $*"
  fi
}

LOGINWINDOW_PLIST="/Library/Preferences/com.apple.loginwindow"
KCPASSWORD_FILE="/etc/kcpassword"

fail() {
  exit 1
}

require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    log "Script must run as root (current EUID: $EUID)"
    fail
  fi
}

remove_autologin_user() {
  if /usr/bin/defaults read "$LOGINWINDOW_PLIST" autoLoginUser >/dev/null 2>&1; then
    log "autoLoginUser exists; attempting removal"
    /usr/bin/defaults delete "$LOGINWINDOW_PLIST" autoLoginUser || fail
    log "autoLoginUser removed"
  else
    log "autoLoginUser key absent; nothing to remove"
  fi
}

remove_kcpassword() {
  if [[ -e "$KCPASSWORD_FILE" ]]; then
    log "$KCPASSWORD_FILE exists; removing"
    /bin/rm -f "$KCPASSWORD_FILE" || fail
    log "$KCPASSWORD_FILE removed"
  else
    log "$KCPASSWORD_FILE not found; nothing to remove"
  fi
}

main() {
  log "Starting deactivate_auto_login script"
  require_root
  remove_autologin_user
  remove_kcpassword
  log "Script completed"
}

main "$@"


# sudo defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser
# 로 값이 비어있는지 확인

#sudo ls /etc/kcpassword
#로 값이 비었는지 확인
