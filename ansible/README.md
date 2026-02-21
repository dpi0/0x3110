# Setup *0x3110* - Ansible Playbook

The `./playbook.yml` contains roles and `./hosts.yml` contains connection configuration.

```bash
ansible-playbook -i ansible/hosts.yml ansible/playbook.yml --ask-become-pass
```

## `packages`

Install listed packages, update package list and upgrade system.

## `time_sync`

This is pretty redundant on a fresh Debian install.

As you can't even run playbook if your system clock is bad.

But still it, sets timezone to default `Asia/Kolkata`.

Configures hardware clock to use UTC `0` and adjusts clock immediately.

Enable and starts `systemd-timesyncd`. NTP client to auto sync and avoid time drift.

## `grub_timeout`

Set GRUB timeout to 0 by updating `/etc/default/grub`.

Run `update-grub` to rebuild configuration.

## `user`

Create groups, create user `div` and add user to those groups.

Create files in `/etc/sudoers.d` - `superuser` and `nopasswdusers`.

Allow only this user to access superuser.

Allow passwordless superuser access as well.

## `ssh`

Again slightly redundant (NOT the `/etc/ssh/ssh_config.d/` hardening part).

As you have to configure ssh first to even run the playbook as non-root.

Create `~/.ssh` directory and place `.pub` key in `authorized_keys` file.

Create `/etc/ssh/ssh_config.d/` directory and place hardened configuration.

Use template for configuration and restart SSH.

## `firewall`

Install `ufw` and set default policy to deny incoming.

Allow these with comments: Samba, HTTP, HTTPS, and SSH (custom).

## `unattended-upgrades`

Allow system upgrades and package updates to happen at a fixed time automatically.

Check `/var/log/unattended-upgrades/unattended-upgrades.log` file for logs.

## `docker`

Install Docker engine following the guide on <https://docs.docker.com/engine/install/debian#install-using-the-repository>.

Create network `traefik`.

## `samba`

Install samba, deploy `smb.conf` via template, restart and enable `smbd` service.

Then manually create user `div`: `sudo smbpasswd -a div` check `sudo pdbedit -L`.
