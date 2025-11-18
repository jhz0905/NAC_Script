#!/bin/bash

set -euo pipefail

exec >/dev/null 2>&1

ZIP_PATH="/Users/Shared/Genians/Resources/083EB6B4A95018111F9AA3116B63FA36D60FC4C3.zip"
DEST_DIR="${ZIP_PATH%.zip}"
INNER_RELATIVE_PATH="Additional Resources"
PKG_NAME="SEP.mpkg"
TARGET_PKG_PATH="$DEST_DIR/$INNER_RELATIVE_PATH/$PKG_NAME"

fail() {
  exit 1
}

ensure_prereqs() {
  command -v unzip >/dev/null 2>&1 || fail
  command -v open >/dev/null 2>&1 || fail
}

extract_archive_if_needed() {
  local zip_parent

  if [[ -e "$TARGET_PKG_PATH" ]]; then
    return
  fi

  if [[ ! -f "$ZIP_PATH" ]]; then
    fail
  fi

  zip_parent="$(dirname "$ZIP_PATH")"
  unzip -q "$ZIP_PATH" -d "$zip_parent"
}

run_installer() {
  if [[ ! -e "$TARGET_PKG_PATH" ]]; then
    fail
  fi

  open "$TARGET_PKG_PATH"
}

main() {
  ensure_prereqs
  extract_archive_if_needed
  run_installer
}

main "$@"
