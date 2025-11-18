#!/bin/bash





####################################################
## 세콰이아 이상은 실행 불가. 프로필 새로 생성하는 방법밖에 없음 ##
####################################################






set -euo pipefail
exec >/dev/null 2>&1

MAXPWAGE_DAYS=90
MINPWAGE_DAYS=1
PW_HISTORY=3
LOCK_THRESH=5
LOCK_DURATION_MIN=10
LOCK_WINDOW_MIN=10
PROFILE_IDENTIFIER="com.codex.passwdpolicy"
PROFILE_PAYLOAD_IDENTIFIER="${PROFILE_IDENTIFIER}.payload"
TMP_PROFILE=""

PRODUCT_VERSION="$(/usr/bin/sw_vers -productVersion)"
PRODUCT_MAJOR="${PRODUCT_VERSION%%.*}"

fail() {
  exit 1
}

is_sequoia_or_newer() {
  [[ "$PRODUCT_MAJOR" -ge 15 ]]
}

ensure_prereqs() {
  if is_sequoia_or_newer; then
    command -v profiles >/dev/null 2>&1 || fail
    command -v uuidgen >/dev/null 2>&1 || fail
  else
    command -v pwpolicy >/dev/null 2>&1 || fail
  fi
}

require_root() {
  [[ "$EUID" -eq 0 ]] || fail
}

apply_policy_pwpolicy() {
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

apply_policy_profile() {
  local max_minutes min_minutes policy_string tmp_profile main_uuid payload_uuid
  max_minutes=$((MAXPWAGE_DAYS * 24 * 60))
  min_minutes=$((MINPWAGE_DAYS * 24 * 60))
  policy_string="maxMinutesUntilChangePassword=$max_minutes;minMinutesUntilChangePassword=$min_minutes;usingHistory=1;passwordHistoryDepth=$PW_HISTORY;maxFailedLoginAttempts=$LOCK_THRESH;minutesUntilFailedLoginReset=$LOCK_WINDOW_MIN;minMinutesUntilFailedLoginReset=$LOCK_DURATION_MIN;"

  tmp_profile="$(mktemp -t passwd_policy).mobileconfig"
  TMP_PROFILE="$tmp_profile"
  trap '[[ -n "$TMP_PROFILE" ]] && /bin/rm -f "$TMP_PROFILE"' EXIT
  main_uuid="$(uuidgen)"
  payload_uuid="$(uuidgen)"

  cat >"$tmp_profile" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>PayloadDescription</key>
      <string>Password policy for local users</string>
      <key>PayloadDisplayName</key>
      <string>Password Policy</string>
      <key>PayloadIdentifier</key>
      <string>${PROFILE_PAYLOAD_IDENTIFIER}</string>
      <key>PayloadType</key>
      <string>com.apple.PasswordPolicy</string>
      <key>PayloadUUID</key>
      <string>${payload_uuid}</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>PasswordPolicy</key>
      <string>${policy_string}</string>
    </dict>
  </array>
  <key>PayloadDisplayName</key>
  <string>Password Policy</string>
  <key>PayloadIdentifier</key>
  <string>${PROFILE_IDENTIFIER}</string>
  <key>PayloadRemovalDisallowed</key>
  <false/>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>${main_uuid}</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>
EOF

  /usr/bin/profiles remove -identifier "$PROFILE_IDENTIFIER" >/dev/null 2>&1 || true
  /usr/bin/profiles install -type configuration -path "$tmp_profile" || fail
  /bin/rm -f "$tmp_profile"
  TMP_PROFILE=""
  trap - EXIT
}

main() {
  ensure_prereqs
  require_root

  if is_sequoia_or_newer; then
    apply_policy_profile
  else
    apply_policy_pwpolicy
  fi
}

main "$@"
