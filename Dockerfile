# syntax=docker/dockerfile:1
# Based on https://github.com/linuxserver/docker-grocy/blob/master/Dockerfile

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.21

ARG BUILD_DATE
ARG GROCY_RELEASE
LABEL build_version="Grocy: ${GROCY_RELEASE}\nBuild-date: ${BUILD_DATE}"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php83-gd \
    php83-intl \
    php83-ldap \
    php83-opcache \
    php83-pdo \
    php83-pdo_sqlite \
    php83-tokenizer && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "**** install grocy ****" && \
  mkdir -p /app/www && \
  curl -o /tmp/grocy.zip -L "https://github.com/nullishamy/open-grocy/releases/download/${GROCY_RELEASE}/grocy.zip" && \
  unzip /tmp/grocy.zip -d /app/www/ && \
  printf "Grocy: ${GROCY_RELEASE}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer

# copy local overlay
COPY docker/root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config