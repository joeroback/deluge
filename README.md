# Deluge
Deluge docker container for TrueNAS SCALE.

## Pull
```
docker pull ghcr.io/joeroback/deluge:latest
```

## run
```
# need to specific port to set in deluge settings and open up on your router
docker run \
  --name deluge \
  --port 8112:8112/tcp \
  --port 61234:61234/tcp \
  --port 61234:61234/udp \
  --volume <path>:/deluge/config \
  --volume <path>:/deluge/downloads \
  ghcr.io/joeroback/deluge:latest
```

## Environment

- `TZ` - Timezone run the container in
- `PUID` - User id to run deluge with
- `PGID` - Group id to run deluge with
- `DELUGE_LOGLEVEL` - [Deluge logging level](https://dev.deluge-torrent.org/wiki/Troubleshooting#AvailableLoglevels), applies to both `deluged` and `deluge-web`

## Ports

- `8112` - Deluge Web UI Port
- `58846` - Deluge Daemon Port
