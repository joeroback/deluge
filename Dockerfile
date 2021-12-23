FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/deluge/config/plugins/.python-eggs"

ENV DELUGE_LOGLEVEL="info"
ENV PUID=1000
ENV PGID=1000
ENV TZ="America/Denver"

RUN \
    apt-get update && \
    apt-get install --yes \
        apt-utils && \
    apt-get dist-upgrade --yes && \
    apt-get install --yes \
        bash \
        coreutils \
        curl \
        gnupg \
        less \
        supervisor \
        tzdata \
        util-linux && \
    ln -fsn /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure tzdata && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C5E6A5ED249AD24C && \
    echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> /etc/apt/sources.list.d/deluge.list && \
    echo "deb-src http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> /etc/apt/sources.list.d/deluge.list && \
    apt-get update && \
    apt-get install --yes \
        deluged \
        deluge-console \
        deluge-web \
        p7zip-full \
        unrar \
        unzip && \
    apt-get autoremove --yes --purge && \
    apt-get clean

RUN \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN \
    groupadd --gid $PGID deluge && \
    useradd --no-create-home --shell /usr/sbin/nologin --gid $PGID --uid $PUID deluge && \
    mkdir -p /deluge/config /deluge/downloads && \
    chown -R deluge:deluge /deluge

EXPOSE 8112/tcp 58846/tcp
VOLUME /deluge/config /deluge/downloads

HEALTHCHECK --interval=1m --timeout=5s \
    CMD curl --fail --silent --output /dev/null http://localhost:8112 || exit 1

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD [ "/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf" ]
