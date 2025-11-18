#!/bin/bash

set -euo pipefail

exec >/dev/null 2>&1

ZIP_PATH="/Users/Shared/Genians/Resources/083EB6B4A95018111F9AA3116B63FA36D60FC4C3.zip"
DEST_DIR="${ZIP_PATH%.zip}"

# 실제 디렉터리 구조 기준으로 수정됨
INNER_RELATIVE_PATH="Additional Resources"
PKG_NAME="SEP.mpkg"

fail() {
  exit 1
}

ensure_prereqs() {
  command -v unzip >/dev/null 2>&1 || fail
  command -v open >/dev/null 2>&1 || fail
}

extract_archive() {
  local zip_parent
  zip_parent="$(dirname "$ZIP_PATH")"

  if [[ ! -f "$ZIP_PATH" ]]; then
    fail
  fi

  if [[ -d "$DEST_DIR" ]]; then
    return
  fi

  unzip -q "$ZIP_PATH" -d "$zip_parent"
}

run_installer() {
  local target_dir="$DEST_DIR/$INNER_RELATIVE_PATH"
  local pkg_path="$target_dir/$PKG_NAME"

  if [[ ! -d "$target_dir" ]]; then
    fail
  fi

  if [[ ! -e "$pkg_path" ]]; then
    fail
  fi

  open "$pkg_path"
}

main() {
  ensure_prereqs
  extract_archive
  run_installer
}

main "$@"
