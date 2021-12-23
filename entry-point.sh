#!/usr/bin/env bash

set -o errexit

# fix timezone
ln -fsn /usr/share/zoneinfo/${TZ} /etc/localtime
dpkg-reconfigure tzdata

# add user
groupadd --gid ${PGID} deluge
useradd --no-create-home --shell /usr/sbin/nologin --gid ${PGID} --uid ${PUID} deluge
mkdir -p /deluge/config /deluge/downloads
chown -R deluge:deluge /deluge

# now that the user is setup, exec into supervisor
exec /usr/bin/supervisord --configuration=/etc/supervisor/conf.d/supervisord.conf
