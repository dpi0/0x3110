# Check Mountpoint Script

Runs a check every N minutes for checking a mount point on the system.

Create the central location for environment variables for the service

```bash
sudo mkdir -p /etc/check-mountpoint
sudo vim /etc/check-mountpoint/env
# add variables

sudo chmod 600 /etc/check-mountpoint/env
sudo chown root:root /etc/check-mountpoint/env
```

Configure service and timer

Avoid symlinking for services to be autorun on startup as `/home` is not there at startup

```bash
cd /path/to/scripts/check-mountpoint

sudo install -m 755 check-mountpoint.sh /usr/local/bin/

sudo install -m 644 check-mountpoint.service /etc/systemd/system/
sudo install -m 644 check-mountpoint.timer /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable --now check-mountpoint.timer
systemctl status check-mountpoint.timer
```

Test manually

```bash
sudo systemctl start check-mountpoint.service
systemctl status check-mountpoint.service

systemctl list-timers check-mountpoint.timer
```
