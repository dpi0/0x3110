# *0x3110*

<img width="100%" height="500" alt="image" src="https://github.com/user-attachments/assets/f481b2a3-1874-437b-a7d6-667eec31c30d" />

Simple Docker Based Home Server Configuration.

The home server is being run on a Samsung NP350V5C "Netbook" from 2013 (my very first machine).

It's glorious current specs are: Intel i3-3110M 2.4GHz quad-core CPU, a whopping 4GB DDR3 memory, 128GB SSD for boot drive and a 1TB external HDD.

This machine is basically soldered into the wall with AC power and no battery. No Wi-Fi, running a 10-gig Ethernet cable on this bad boy.

Also, I've removed its display so it's kinda a leaner C64.

Services that are meant to be run are present in `./compose.yaml`. To spin up: `docker compose up -d` in the root directory.

I've obviously excluded all instances of `.env` file from this repository. Fill it with your own values.

The "archived" services are in `./services/` which I don't intend to run ATM. Barring `./services/immich/` (this beast needed it's own directory and separate configuration).

For some services (like beets) which needed a long and separate configuration file, they have the `./config/` directory to them.

Helper scripts (for notifications, alerting etc.) are placed in `./scripts/`.

Wiki for most services is present below.

## Docker Socket Proxy

<https://github.com/wollomatic/socket-proxy>

<https://github.com/wollomatic/traefik-hardened/blob/master/docker-compose.yaml>

Why? <https://reddit.com/r/Traefik/comments/1o0llw0/do_you_use_a_docker_socket_proxy/>

- Containers have access to `docker.sock`, if something goes wrong with the image, bad actor can perform any malicious action
- `socket-proxy` gives only certain selected permissions (least privilege)

## Traefik - Reverse Proxy

<https://github.com/traefik/traefik>

<https://doc.traefik.io/traefik/getting-started/docker/>

- Traefik provides docker labels to configure settings, has excellent middleware support (when needed)
- Handles HTTPs certs very well

For this service you need an external network: `docker network create traefik`

## Diun - Docker Image Update Notifer

<https://github.com/crazy-max/diun>

<https://crazymax.dev/diun/install/docker/>

- Sends a periodic notification when a docker image has a newer version available
- Using the telegram provider currently

## qBittorrent - Torrent Client

<https://github.com/qbittorrent/qBittorrent>

<https://github.com/qbittorrent/qBittorrent/wiki/Installing-qBittorrent>

The best torrent client.

## Jellyfin - Media Library

<https://github.com/jellyfin/jellyfin>

<https://jellyfin.org/docs/general/installation/container>

The best media server.

## Syncthing - File synchronization

<https://github.com/syncthing/syncthing>

<https://docs.linuxserver.io/images/docker-syncthing/#docker-compose-recommended-click-here-for-more-info>

The best file synchronizer.

## Newt - Tunneling Client for Pangolin

<https://github.com/fosrl/newt>

<https://docs.pangolin.net/self-host/manual/docker-compose#docker-compose-configuration>

Allows machines to connect to the Pangolin server via tunnels.

## Backrest - Restic Backup with GUI

<https://github.com/garethgeorge/backrest#running-with-docker-compose>

<https://garethgeorge.github.io/backrest/introduction/getting-started/#_1-instance-configuration>

Take restic backups (rclone, sftp, http).

## Beszel - Lightweight Server Monitoring

<https://github.com/henrygd/beszel>

<https://beszel.dev/guide/hub-installation>

<https://beszel.dev/guide/agent-installation>

<https://beszel.dev/guide/environment-variables>

- Works very well with docker.sock
- And gives you all the necessary data (cpu, ram, load, temp, bandwidth, swap)

After launching beszel-hub and heading to <https://beszel.home.DOMAIN/>,

- Hit "Add System"
- Set an arbitary name like "agent-docker"
- set "Host/IP" = "beszel-agent"
- Copy the "Public Key" and replace the $BESZEL_AGENT_SSH_KEY env variable
- Restart the beszel-agent service.

For the beszel-agent-intel-gpu, configure this kernel parameter on bare metal otherwise it shows "Failed to initialize PMU! (Permission denied)" error.

<https://github.com/henrygd/beszel/issues/1150#issuecomment-3475126281>

```bash
sudo sysctl kernel.perf_event_paranoid=0
```

## `mount-point-alert.go`

Provides alerting for drive mount connection.

Build

```bash
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o mount-point-alert ./scripts/mount-point-alert.go
```

And move the built `mount-point-alert` binary to `/usr/local/bin/mount-point-alert`

Create `/etc/systemd/system/mount-point-alert.service`

```bash
[Unit]
Description=Mount Point Alert
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/mount-point-alert
Restart=always
User=nobody
CapabilityBoundingSet=
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
```

And, `sudo systemctl daemon-reload && sudo systemctl enable --now mount-point-alert; systemctl status mount-point-alert`

## Navidrome - Music Server

<https://www.navidrome.org/docs/installation/docker/>

The best music server.

## slskd - Soulseek

<https://github.com/slskd/slskd/blob/master/docs/docker.md>

Connect to the Soulseek network.

## beets - Audio Organization

<https://beets.readthedocs.io/en/stable/guides/installation.html>

Metadata and tagging for audio files. Organize your downloaded audio into a library.

## cgit - Git Frontend

<https://git.zx2c4.com/cgit/about/>

A fast web frontend for git repositories.

On the server, fix the permissions for your bare git repos in `/srv/git`

```bash
sudo chown -R git:git /srv/git

# Allow traversal into /srv and /srv/git
sudo chmod 755 /srv
sudo chmod 755 /srv/git

# Make repos and their subdirs world-readable & traversable
sudo find /srv/git -type d -exec chmod 755 {} \;
sudo find /srv/git -type f -exec chmod 644 {} \;
```

## Forgejo - Git Forge

<https://forgejo.org/docs/latest/admin/installation/docker/>

To push an existing repo to forgejo's internal `/data/git/repositories` structure,

Copy your public key `cat ~/.ssh/git-homeserver.pub | wl-copy` and add it to `https://forgejo.home.DOMAIN/user/settings/keys`

Edit your `~/.ssh/config` to add,

```text
Host forgejo
  HostName 10.0.0.10
  User git
  IdentityFile ~/.ssh/git-homeserver
  Port 7129
  IdentitiesOnly yes
```

Make sure to have this key loaded in your shell env,

```bash
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
# Configure the SSH socket
if [[ -z "${SSH_CONNECTION}" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Add your key
if ! ssh-add -l 2>/dev/null | grep -q git-homeserver; then
    ssh-add ~/.ssh/git-homeserver >/dev/null 2>&1
fi
```

And in your local repo,

```bash
git remote add forgejo forgejo:dpi0/notes.git

git push forgejo main --force
```

## Notes

Serves the build mkdocs site in `/srv`.

## Memos - Notes

<https://github.com/usememos/memos>

<https://usememos.com/docs/installation/docker>

Provides a nice way to take quick notes
