FROM ubuntu:20.04

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
        gnupg \
        openssl \
        supervisor \
        tzdata \
        util-linux && \
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

EXPOSE 8112/tcp 58846/tcp
VOLUME /deluge/config /deluge/downloads

HEALTHCHECK --interval=1m --timeout=5s \
    CMD curl --fail --silent --output /dev/null http://localhost:8112 || exit 1

# fix for weak ssl used on some trackers
RUN \
    echo "openssl_conf = default_conf" > /etc/ssl/openssl_weak.cnf && \
    cat /etc/ssl/openssl.cnf >> /etc/ssl/openssl_weak.cnf && \
    echo "\
[default_conf]\n\
ssl_conf = ssl_sect\n\
[ssl_sect]\n\
system_default = system_default_sect\n\
[system_default_sect]\n\
MinProtocol = TLSv1.2\n\
CipherString = DEFAULT:@SECLEVEL=1\n\
" >> /etc/ssl/openssl_weak.cnf && \
    ln -sf /etc/ssl/openssl_weak.cnf /etc/ssl/openssl.cnf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entry-point.sh /entry-point.sh

CMD [ "/entry-point.sh" ]
