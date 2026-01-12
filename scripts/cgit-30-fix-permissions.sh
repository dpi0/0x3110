#!/bin/sh
set -eu

# Ensure fcgiwrap runtime dir exists and is writable by CGIT_APP_USER
mkdir -p /run/fcgiwrap
chown -R "${CGIT_APP_USER}:${CGIT_APP_USER}" /opt/cgit/ /run/fcgiwrap/
chmod 770 /opt/cgit/ /opt/cgit/filters/ /opt/cgit/app/ /opt/cgit/cache/ /run/fcgiwrap/

# Do NOT touch /opt/git; it is a bind mount from the host and may be read-only
echo "Fixed permissions for /run/fcgiwrap, skipped /opt/git"
