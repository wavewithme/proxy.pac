#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="https://raw.githubusercontent.com/onminonA/proxy.pac/main/proxy.pac"
UPSTREAM_PROXY="127.0.0.1:1080"
LOCAL_PROXY="127.0.0.1:10808"
TARGET="proxy.pac"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl --fail --silent --show-error --location "$UPSTREAM_URL" --output "$tmp"

if ! grep -Eq '127\.0\.0\.1:1080([^0-9]|$)' "$tmp"; then
  echo "Upstream PAC no longer contains an exact $UPSTREAM_PROXY endpoint; refusing to overwrite $TARGET."
  exit 1
fi

perl -pe 's/127\.0\.0\.1:1080(?![0-9])/127.0.0.1:10808/g' "$tmp" > "$TARGET"

if grep -Eq '127\.0\.0\.1:1080([^0-9]|$)' "$TARGET"; then
  echo "Port replacement failed; refusing to continue."
  exit 1
fi

if ! grep -Eq '127\.0\.0\.1:10808([^0-9]|$)' "$TARGET"; then
  echo "Patched PAC does not contain the expected $LOCAL_PROXY endpoint; refusing to continue."
  exit 1
fi

echo "PAC updated from upstream and patched to use $LOCAL_PROXY."
