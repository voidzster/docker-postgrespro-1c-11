FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

RUN groupadd postgres --gid=999 \
  && useradd --gid postgres --uid=999 postgres

ENV GOSU_VERSION 1.7
RUN apt-get -qq update \
  && apt-get -qq install --yes --no-install-recommends ca-certificates wget locales pigz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

ENV SERVER_VERSION 1c-11
ENV PATH /opt/pgpro/$SERVER_VERSION/bin:$PATH
ENV PGDATA /data

RUN apt-get update -y \
    && apt-get install -y wget gnupg2 || apt-get install -y gnupg \
    && wget -O - http://repo.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO | apt-key add - \
    && echo deb http://repo.postgrespro.ru/1c-archive/pg1c-11.1/ubuntu/ bionic main > /etc/apt/sources.list.d/postgrespro-1c.list \
    && apt-get update -y \
    && apt-get install -y postgrespro-1c-11-server postgrespro-1c-11-contrib \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir --parent /var/run/postgresql "$PGDATA" /docker-entrypoint-initdb.d \
  && chown --recursive postgres:postgres /var/run/postgresql "$PGDATA" \
  && chmod g+s /var/run/postgresql

COPY container/docker-entrypoint.sh /
COPY container/postgresql.conf.sh /docker-entrypoint-initdb.d

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA

EXPOSE 5432

CMD ["postgres"]
