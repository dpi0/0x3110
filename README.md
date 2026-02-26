# *0x3110*

<img width="100%" height="500" alt="image" src="https://github.com/user-attachments/assets/f481b2a3-1874-437b-a7d6-667eec31c30d" />

Docker Based Home Server Configuration.

The home server is being run on a Samsung NP350V5C "Netbook" from 2013 (my very first machine).

It's glorious current specs are: Intel i3-3110M 2.4GHz quad-core CPU, a whopping 4GB DDR3 memory, 128GB SSD for boot drive and a 1TB external HDD.

This machine is basically soldered into the wall with AC power and no battery. No Wi-Fi, running a 10-gig Ethernet cable on this bad boy.

Also, I've removed its display so it's almost a leaner C64.

## Directory Structure

- Services are defined using individual compose files in `./services`. Like for Jellyfin we have `./services/compose-jellyfin.yaml`
- The "entrypoint" file `./compose.yaml` allows me easily "enable/disable" each service by simply commenting out that service.
- Immich, being the beast it is, needed it's own seperate directory in `./services/immich/`
- I've obviously excluded all instances of `.env` file from this repository. Fill it with your own values.
- For some services (like beets) which needed a long and separate configuration file, they have the `./config/` directory to them.
- Helper scripts (for notifications, alerting etc.) are placed in `./scripts/`.

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
- Using the discord provider currently

## qBittorrent - Torrent Client

<https://github.com/qbittorrent/qBittorrent>

<https://github.com/qbittorrent/qBittorrent/wiki/Installing-qBittorrent>

<https://github.com/VueTorrent/VueTorrent/wiki/Installation>

The best torrent client.

For custom web UI, use the latest release of [VueTorrent](https://github.com/VueTorrent/VueTorrent).

Clone the stable branch repository in `$DATA/docker/qbittorrent/themes` directory.

```bash
git clone --single-branch --branch latest-release https://github.com/VueTorrent/VueTorrent.git

# update anytime using
git pull
```

In the qbittorrent settings UI, `WebUI` > check `Use alternative WebUI` and `Files location` = `/themes/VueTorrent`

Import the json settings for VueTorrent UI.

<img width="216" height="150" alt="image" src="https://github.com/user-attachments/assets/7a3696c7-3f45-41ba-a5bb-78c7008e173a" />
<br>
<em>qb stats as of Feb 2026 🏴‍☠️</em>

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

Repositories

1. Bind mount the `rclone.conf` with `dpi0dev-google-drive` configuration present.
2. Repository URI: `rclone:dpi0dev-google-drive:PATH_ON_GDRIVE`
3. Set Prune and Check policy to `30` days.
4. Enable auto unlock (for single user only).

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

Set `Webhook / Push notifications` in <https://beszel.home.DOMAIN/settings/notifications> using `Shoutrrr`

For telegram the format is `telegram://BOT_TOKEN@telegram?chats=CHAT_ID`

For the `beszel-agent-intel-gpu`, configure this kernel parameter on bare metal otherwise it shows "Failed to initialize PMU! (Permission denied)" error.

<https://github.com/henrygd/beszel/issues/1150#issuecomment-3475126281>

```bash
sudo sysctl kernel.perf_event_paranoid=0
```

<img width="710" height="400" alt="image" src="https://github.com/user-attachments/assets/6ef84b78-bad3-4b60-8c8a-7cbcd34fd5b5" />

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

---

*Source for banner image: <https://wallhaven.cc/w/rrkg9m>*
