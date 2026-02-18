#!/bin/sh

while [ $# -gt 0 ]; do
  case "$1" in
  --bot-token)
    BOT_TOKEN="$2"
    shift 2
    ;;
  --chat-id)
    CHAT_ID="$2"
    shift 2
    ;;
  *) break ;;
  esac
done

[ -z "$BOT_TOKEN" ] && exit 1
[ -z "$CHAT_ID" ] && exit 1

NAME="$1"
CATEGORY="$2"
CONTENT_PATH="$3"
FILE_COUNT="$4"
SIZE_BYTES="$5"

[ -z "$CATEGORY" ] && CATEGORY="Uncategorized"

echo "$SIZE_BYTES" | grep -qE '^[0-9]+$' || SIZE_BYTES=0

if [ "$SIZE_BYTES" -lt 1073741824 ]; then
  SIZE=$(printf "%.2f MB" "$(echo "$SIZE_BYTES / 1048576" | bc -l)")
else
  SIZE=$(printf "%.2f GB" "$(echo "$SIZE_BYTES / 1073741824" | bc -l)")
fi

MESSAGE="🌀 <b>qBittorrent</b>
----------------------------
✅ $NAME
$SIZE • $FILE_COUNT files
$CATEGORY

$CONTENT_PATH"

curl -s \
  -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  --data chat_id="$CHAT_ID" \
  --data parse_mode="HTML" \
  --data-urlencode text="$MESSAGE"
