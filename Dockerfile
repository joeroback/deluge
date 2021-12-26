FROM ubuntu:18.04

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="true"
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/deluge/config/plugins/.python-eggs"

ENV DELUGE_LOGLEVEL="warning"
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
        openssl \
        supervisor \
        tzdata \
        util-linux && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C5E6A5ED249AD24C && \
    echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu bionic main" >> /etc/apt/sources.list.d/deluge.list && \
    echo "deb-src http://ppa.launchpad.net/deluge-team/stable/ubuntu bionic main" >> /etc/apt/sources.list.d/deluge.list && \
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

EXPOSE 8112/tcp 58846/tcp
VOLUME /deluge/config /deluge/downloads

HEALTHCHECK --interval=1m --timeout=5s \
    CMD curl --fail --silent --output /dev/null http://localhost:8112 || exit 1

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entry-point.sh /entry-point.sh

CMD [ "/entry-point.sh" ]
