FROM php:7.3-apache

LABEL maintainer="Alwyn Kik <alwyn@kik.pw>"
LABEL docker_image_repo="https://github.com/Alveel/docker-dokuwiki-nonroot"
LABEL docker_image_version="0.1"

ENV DOKUWIKI_VERSION="2018-04-22b" \
    DOKUWIKI_MD5SUM="605944ec47cd5f822456c54c124df255" \
    DOKUWIKI_WEBROOT=/var/www/html

WORKDIR /tmp/setup

# Download and install the specified DokuWiki release
RUN curl --remote-name --silent "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz" && \
    echo "${DOKUWIKI_MD5SUM}  dokuwiki-${DOKUWIKI_VERSION}.tgz" | md5sum -c - && \
    tar xf "dokuwiki-${DOKUWIKI_VERSION}.tgz" && \
    rmdir /var/www/html && \
    mv "dokuwiki-${DOKUWIKI_VERSION}" "${DOKUWIKI_WEBROOT}" && \
    rm -r /tmp/setup

VOLUME "${DOKUWIKI_WEBROOT}/conf"
VOLUME "${DOKUWIKI_WEBROOT}/data"
VOLUME "${DOKUWIKI_WEBROOT}/lib/plugins"
VOLUME "${DOKUWIKI_WEBROOT}/lib/tpl"

EXPOSE 8080

WORKDIR "${DOKUWIKI_WEBROOT}"

COPY entrypoint.sh /docker-entrypoint.sh

# Configure PHP and Apache
RUN chmod 0754 /docker-entrypoint.sh && \
    sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's/80/8080/g' /etc/apache2/ports.conf && \
    a2enmod rewrite && \
    cp "${PHP_INI_DIR}"/php.ini-production "${PHP_INI_DIR}"/conf.d/php.ini && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/g' "${PHP_INI_DIR}"/conf.d/php.ini

# Configure DokuWiki
RUN head -n -6 "${DOKUWIKI_WEBROOT}"/.htaccess.dist > "${DOKUWIKI_WEBROOT}"/.htaccess.bak && \
    sed -i 's/#Options/Options/' "${DOKUWIKI_WEBROOT}"/.htaccess.bak && \
    sed -i 's/#Rewrite/Rewrite/g' "${DOKUWIKI_WEBROOT}"/.htaccess.bak && \
    sed -i 's/RewriteBase \/dokuwiki/RewriteBase \//' "${DOKUWIKI_WEBROOT}"/.htaccess.bak && \
    mv "${DOKUWIKI_WEBROOT}"/.htaccess.bak "${DOKUWIKI_WEBROOT}"/.htaccess && \
    chgrp -R 0 "${DOKUWIKI_WEBROOT}" && \
    chmod -R g=u "${DOKUWIKI_WEBROOT}"

USER 1001

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2-foreground" ]

