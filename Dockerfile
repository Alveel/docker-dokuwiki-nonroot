FROM php:7.3-fpm-alpine

ENV DOKUWIKI_VERSION="2018-04-22b" \
    DOKUWIKI_MD5SUM="605944ec47cd5f822456c54c124df255" \
    DOKUWIKI_FULLNAME="Admin User" \
    DOKUWIKI_EMAIL="user@example.com" \
    DOKUWIKI_USERNAME="admin" \
    DOKUWIKI_PASSWORD="MagicPotato" \
    DOKUWIKI_NAME="Docker DokuWiki"

WORKDIR /tmp/setup

RUN curl --remote-name --quiet "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_VERSION}.tgz" && \
    echo "${DOKUWIKI_MD5SUM}  dokuwiki-${DOKUWIKI_VERSION}.tgz" | md5sum -c - && \
    tar xf "dokuwiki-${DOKUWIKI_VERSION}.tgz" && \
    mv "dokuwiki-${DOKUWIKI_VERSION}" /var/www/dokuwiki

