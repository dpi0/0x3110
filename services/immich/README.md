# Immich

<https://docs.immich.app/install/docker-compose/>

Fetch files

```bash
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml

# Do not use .env filename for the downloaded file. Rename manually.
wget -O example.env https://github.com/immich-app/immich/releases/latest/download/example.env
```

Fix `compose.yaml`

Comment out the `immich-machine-learning` block.

Add these in `immich-server` > `volumes`,

```yaml
- $EXTERNAL_DIV_PHOTOS:/external/div/photos:ro
- $EXTERNAL_DIV_VIDEOS:/external/div/videos:ro
```

Fix `.env`

Add

```bash
EXT_PHOTOS=/data/archive/photos
EXT_VIDEOS=/data/archive/videos
```

Replace

```bash
UPLOAD_LOCATION=/data/Immich
DB_DATA_LOCATION=/opt/docker/data/immich/postgres
TZ=Asia/Kolkata
IMMICH_VERSION=v2.3.1
```

Store `DB_PASSWORD` (in Bitwarden)

---

## Backup

> [!IMPORTANT]
> Copy ALL the damn contents of `/data/immich`.
>
> It will take time but trust me, grab everything! (except `thumbs`)

COPY EVERYTHING!

```bash
docker compose down

# use sudo to preseve ownership correctly
# exclude the /data/immich/thumbs but keep the .immich file in there
sudo rsync -aHAX --info=progress2 --exclude='thumbs/**/*' /data/immich /path/to/new/storage
```

<https://docs.immich.app/administration/backup-and-restore/#restore-cli>

Do not backup the raw database.

`/opt/immich/postgres` or `DB_DATA_LOCATION` is not needed at all.

Most important directory is `/data/immich/library`. As it holds the raw media files.

Manual backup

```bash
docker compose up -d
# whole of immmich needs to be running

docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "/data/docker/immich/backup-manual-$(date +'%d-%b-%Y_%H-%M-%S').sql.gz"

# shut it down
docker compose down
```

Run

```bash
sudo rsync -aHAX --info=progress2 --exclude='thumbs/**/*' /data/immich /path/to/new/storage
```

You have two things to restore with:

1. `/path/to/new/storage` the entire immich directory with correct ownership and permissions. Place it in `/data/immich`.

    ```bash
    sudo rsync -aHAX --info=progress2 /path/to/new/storage /data/
    ```

2. `/data/docker/immich/backup-manual-TIMESTAMP.sql.gz` the database backup. Keep it as it as.

Manual restore

```bash
docker compose pull
docker compose create
docker start immich_postgres
sleep 10

gunzip --stdout "/data/docker/immich/backup-manual-TIMESTAMP.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich_postgres psql --dbname=postgres --username=postgres

docker compose up -d

docker logs -f immich_server
```

If immich complains about the `.immich` file

```bash
docker compose down

sudo mkdir -p /data/immich/thumbs
sudo touch /data/immich/thumbs/.immich
sudo chown -R $(stat -c "%u:%g" /data/immich/library) /data/immich/thumbs

docker compose up -d
```
