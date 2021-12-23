# Deluge
Deluge docker container for TrueNAS SCALE
(GitHub)[https://github.com/joeroback/deluge]

## Environment

- `TZ` - Timezone run the container in
- `PUID` - User id to run deluge with
- `PGID` - Group id to run deluge with
- `DELUGE_LOGLEVEL` - [Deluge logging level](https://dev.deluge-torrent.org/wiki/Troubleshooting#AvailableLoglevels), applies to both `deluged` and `deluge-web`

## Ports

- `8112` - Deluge Web UI Port
- `58846` - Deluge Daemon Port
