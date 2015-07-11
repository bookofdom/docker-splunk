FROM ubuntu:trusty

MAINTAINER Denis Gladkikh <splunk@denis.gladkikh.email>

ENV SPLUNK_PRODUCT splunk
ENV SPLUNK_VERSION 6.2.4
ENV SPLUNK_BUILD 271043
ENV SPLUNK_MD5SUM b54ac1550841588d152eb12514ecfb2c

ENV SPLUNK_HOME /opt/splunk
ENV SPLUNK_GROUP splunk
ENV SPLUNK_USER splunk
ENV SPLUNK_BACKUP_DEFAULT_ETC /var/opt/splunk

# add splunk:splunk user
RUN groupadd -r ${SPLUNK_GROUP} \
    && useradd -r -g ${SPLUNK_GROUP} ${SPLUNK_USER}

# make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
RUN apt-get update \
    && apt-get install -y wget \
    && mkdir -p ${SPLUNK_HOME} \
    && wget -qO /tmp/splunk.tgz http://www.splunk.com/bin/splunk/DownloadActivityServlet\?architecture\=x86_64\&platform\=Linux\&version\=${SPLUNK_VERSION}\&product\=${SPLUNK_PRODUCT}\&filename\=${SPLUNK_PRODUCT}-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.tgz\&wget\=true \
    && (cd /tmp && echo "${SPLUNK_MD5SUM} splunk.tgz" >> /tmp/splunk.tgz.md5 && md5sum -c splunk.tgz.md5) \
    && tar xzf /tmp/splunk.tgz --strip 1 -C $SPLUNK_HOME \
    && rm /tmp/splunk.tgz \
    && apt-get purge -y --auto-remove wget \
    && mkdir -p /var/opt/splunk \
    && cp -R ${SPLUNK_HOME}/etc ${SPLUNK_BACKUP_DEFAULT_ETC} \
    && rm -fR ${SPLUNK_HOME}/etc \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_HOME} \
    && chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_BACKUP_DEFAULT_ETC}

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

# Ports Splunk Web, Splunk Daemon, KVStore
EXPOSE 8000 8089 8191

WORKDIR /opt/splunk

# Configurations folder, var folder for everyting (indexes, logs, kvstore)
VOLUME [ "/opt/splunk/etc", "/opt/splunk/var" ]

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["start-service"]
