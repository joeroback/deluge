FROM ubuntu:20.04

LABEL org.opencontainers.image.source="https://github.com/joeroback/deluge"

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="true"
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/deluge/config/plugins/.python-eggs"

ENV DELUGE_LOGLEVEL="info"
ENV PUID=1000
ENV PGID=1000
ENV TZ="America/Denver"

RUN \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        apt-utils && \
    apt-get dist-upgrade --yes

RUN \
    apt-get install --yes --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        curl \
        gnupg \
        nano \
        openssl \
        p7zip-full \
        supervisor \
        tzdata \
        unrar \
        unzip \
        util-linux

RUN \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8EED8FB4A8E6DA6DFDF0192BC5E6A5ED249AD24C && \
    echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> /etc/apt/sources.list.d/deluge.list && \
    echo "deb-src http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> /etc/apt/sources.list.d/deluge.list && \
    apt-get update && \
    apt-get install --yes \
        deluged \
        deluge-console \
        deluge-web && \
    apt-get autoremove --yes --purge && \
    apt-get clean

# older trackers with poor ssl settings fail on 20.04+
COPY openssl_weak.cnf /tmp

RUN \
    cat /tmp/openssl_weak.cnf /etc/ssl/openssl.cnf > /tmp/openssl.cnf && \
    cp /tmp/openssl.cnf /etc/ssl/openssl.cnf

RUN \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

EXPOSE 8112/tcp 58846/tcp
VOLUME /deluge/config /deluge/downloads

HEALTHCHECK --interval=1m --timeout=5s \
    CMD curl --fail --silent --output /dev/null http://localhost:8112 || exit 1

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entry-point.sh /entry-point.sh

CMD [ "/entry-point.sh" ]
