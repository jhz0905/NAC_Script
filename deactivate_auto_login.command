#!/bin/bash

set -euo pipefail
exec >/dev/null 2>&1

LOGINWINDOW_PLIST="/Library/Preferences/com.apple.loginwindow"
KCPASSWORD_FILE="/etc/kcpassword"

fail() {
  exit 1
}

require_root() {
  [[ "$EUID" -eq 0 ]] || fail
}

remove_autologin_user() {
  if /usr/bin/defaults read "$LOGINWINDOW_PLIST" autoLoginUser >/dev/null 2>&1; then
    /usr/bin/defaults delete "$LOGINWINDOW_PLIST" autoLoginUser || fail
  fi
}

remove_kcpassword() {
  if [[ -e "$KCPASSWORD_FILE" ]]; then
    /bin/rm -f "$KCPASSWORD_FILE" || fail
  fi
}

main() {
  require_root
  remove_autologin_user
  remove_kcpassword
}

main "$@"


# sudo defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser
# 로 값이 비어있는지 확인

#sudo ls /etc/kcpassword
#로 값이 비었는지 확인