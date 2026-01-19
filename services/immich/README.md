# Immich

Docker: <https://docs.immich.app/install/docker-compose/>

```bash
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml

wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
```

## `./compose.yaml`

- Comment out the `immich-machine-learning` block.
- Add these in `immich-server` > `volumes`,

```yaml
      - ${EXT_PHOTOS}:/external/photos:ro
      - ${EXT_VIDEOS}:/external/videos:ro
```

## `./.env`

- Add,

```bash
EXT_PHOTOS=/hdd/Library/Photos
EXT_VIDEOS=/hdd/Library/Videos
```

- Replace,

```bash
UPLOAD_LOCATION=/hdd/Library/Immich
DB_DATA_LOCATION=/opt/docker/data/immich/postgres
TZ=Asia/Kolkata
IMMICH_VERSION=v2.3.1
```

- Add `DB_PASSWORD` (in Bitwarden)

> [!NOTE]
> To backup, `DB_DATA_LOCATION` is not needed. Do not backup the raw database.
>
> Immich will auto generate Postgres DB Backups regularly and place them in `UPLOAD_LOCATION/backups`.
>
> So make sure to backup this up. And run the restore <https://docs.immich.app/administration/backup-and-restore#manual-backup-and-restore>.
