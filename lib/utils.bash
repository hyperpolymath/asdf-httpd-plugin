#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="httpd"
BINARY_NAME="httpd"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  curl -sL "https://downloads.apache.org/httpd/" 2>/dev/null | \
    grep -oE 'httpd-[0-9]+\.[0-9]+\.[0-9]+\.tar' | sed 's/httpd-//;s/\.tar$//' | sort -V | uniq
}

download_release() {
  local version="$1" download_path="$2"
  local url="https://downloads.apache.org/httpd/httpd-${version}.tar.gz"

  echo "Downloading Apache HTTPD $version..."
  mkdir -p "$download_path"
  curl -fsSL "$url" -o "$download_path/httpd.tar.gz" || fail "Download failed"
  tar -xzf "$download_path/httpd.tar.gz" -C "$download_path" --strip-components=1
  rm -f "$download_path/httpd.tar.gz"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"

  cd "$ASDF_DOWNLOAD_PATH"
  ./configure --prefix="$install_path" || fail "Configure failed"
  make -j"$(nproc)" || fail "Build failed"
  make install || fail "Install failed"
}
