#!/usr/bin/env bash

# shellcheck disable=SC1091
set -a
source "$(dirname -- "${BASH_SOURCE[0]}")/.env" 2>/dev/null
set +a

discord_webhook_url="${DISCORD_WEBHOOK_URL:?DISCORD_WEBHOOK_URL not set}"
torrent_name="$1"
size="$2"
files="$3"
# tracker="$4"
category="$5"
path="$6"

case "$category" in
"Films") download_type="Films" ;;
"Shows") download_type="Shows" ;;
"Movies") download_type="Movies" ;;
"TV") download_type="TV" ;;
*) download_type="Files - Uncategorised" ;;
esac

torrent_size=$(echo "$size" | numfmt --to=iec)

payload=$(
    cat <<EOF
{
  "embeds": [
    {
      "author": {
        "name": "qBittorrent",
        "icon_url": "https://i.imgur.com/6LTKLgZ.jpg"
      },
      "title": "Download completed: $torrent_name",
      "color": 7506394,
      "fields": [
        {
          "name": "Torrent",
          "value": "$torrent_name"
        },
        {
          "name": "Save Path",
          "value": "$path"
        },
        {
          "name": "Category",
          "value": "$download_type",
          "inline": true
        },
        {
          "name": "Size",
          "value": "$torrent_size",
          "inline": true
        },
        {
          "name": "Files",
          "value": "$files",
          "inline": true
        }
      ]
    }
  ]
}
EOF
)

curl -s -H "Content-Type: application/json" \
    -X POST \
    -d "$payload" \
    "$discord_webhook_url" >/dev/null
