#!/usr/bin/env bash

discord_webhook_url=""
while [[ $# -gt 0 ]]; do
    case "$1" in
    --discord-webhook-url)
        [[ -n "$2" && "$2" =~ ^https?://[^[:space:]]+$ ]] || exit 1
        discord_webhook_url="$2"
        shift 2
        ;;
    *)
        break
        ;;
    esac
done

torrent_name="$1"
size="$2"
files="$3"
# tracker="$4"
category="$4"
path="$5"

case "$category" in
"Films") download_type="Films" ;;
"Shows") download_type="Shows" ;;
"Movies") download_type="Movies" ;;
"TV") download_type="TV" ;;
*) download_type="Files/Uncategorised" ;;
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
      "title": "Completed: $torrent_name",
      "color": 7506394,
      "fields": [
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

[[ -n "$discord_webhook_url" ]] || exit 1

curl -s -H "Content-Type: application/json" \
    -X POST \
    -d "$payload" \
    "$discord_webhook_url" >/dev/null
