#!/usr/bin/env bash

: "${MOUNTPOINT:?Missing MOUNTPOINT}"
: "${TG_TOKEN:-}"
: "${TG_CHAT:-}"

if [[ -z "$TG_TOKEN" || -z "$TG_CHAT" ]]; then
  echo "no notification method specified" >&2
  exit 1
fi

if ! mountpoint -q "$MOUNTPOINT"; then
  TS=$(date '+[%H:%M:%S, %d %b %y]')
  MSG="💿 $MOUNTPOINT not mounted! $TS"
else
  exit 0
fi

curl -s -X POST \
  "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
  -d "chat_id=${TG_CHAT}" \
  -d "text=${MSG}" >/dev/null
