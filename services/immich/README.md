# Immich

<https://docs.immich.app/install/docker-compose/>

```bash
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml

# Do not use .env filename for the downloaded file. Rename manually.
wget -O example.env https://github.com/immich-app/immich/releases/latest/download/example.env
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

Manual database backup (need the `immich_postgres` container to be running)

```bash
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "/data/immich/backup-manual-$(date +'%d-%b-%Y_%H-%M-%S').sql.gz"
```

Manual restore (when starting from scratch)

```bash
docker compose pull
docker compose create
docker start immich_postgres
sleep 10

gunzip --stdout "/data/immich/backup-manual-TIMESTAMP.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich_postgres psql --dbname=postgres --username=postgres

docker compose up -d
```
