# Base Vapor PHP 8.2 construida aqui a partir de laravel/vapor-dockerfiles@7bd055c (php82.Dockerfile),
# porque a laravelphp/vapor:php82 parou no 8.2.35. Unica mudanca no estagio vapor: o FROM
# aponta pro 8.2.36 e o runtime vem de vapor-runtime/. Voltar pro FROM laravelphp/vapor:php82
# quando a Laravel publicar a correcao. Agente New Relic travado na 12.12.0.41, a mesma da
# imagem anterior, pra que a unica mudanca seja o PHP.
FROM --platform=linux/amd64 php:8.2.36-fpm-alpine AS vapor

# The php base image lags Alpine's package repository, so upgrade what it ships
# before adding anything else, and require a minimum brotli-libs version.
RUN apk upgrade --no-cache && \
    apk add --no-cache 'brotli-libs>=1.2.1-r0'

RUN apk --update add \
    wget \
    curl \
    build-base \
    libmcrypt-dev \
    libxml2-dev \
    pcre-dev \
    zlib-dev \
    autoconf \
    oniguruma-dev \
    openssl \
    openssl-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    jpeg-dev \
    libpng-dev \
    imagemagick-dev \
    imagemagick \
    postgresql-dev \
    libzip-dev \
    gettext-dev \
    libxslt-dev \
    libgcrypt-dev \
    linux-headers && \
    rm /var/cache/apk/*

RUN pecl channel-update pecl.php.net && \
    pecl install mcrypt redis-5.3.7 && \
    rm -rf /tmp/pear

RUN docker-php-ext-install \
    mysqli \
    mbstring \
    pdo \
    pdo_mysql \
    xml \
    pcntl \
    bcmath \
    pdo_pgsql \
    zip \
    intl \
    gettext \
    soap \
    sockets \
    xsl

RUN docker-php-ext-configure gd --with-freetype=/usr/lib/ --with-jpeg=/usr/lib/ && \
    docker-php-ext-install gd

RUN docker-php-ext-enable redis

RUN cp "/etc/ssl/cert.pem" /opt/cert.pem

COPY vapor-runtime/bootstrap /opt/bootstrap
COPY vapor-runtime/bootstrap.php /opt/bootstrap.php
COPY vapor-runtime/php.ini /usr/local/etc/php/php.ini

# Sometimes opcache is already included via /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
# but we add it if not
RUN if ! php -m | grep -q "Zend OPcache"; then \
       echo "zend_extension=opcache.so" >> /usr/local/etc/php/php.ini; \
   fi

RUN chmod 755 /opt/bootstrap
RUN chmod 755 /opt/bootstrap.php

ENTRYPOINT []

CMD /opt/bootstrap

FROM vapor

ARG NEW_RELIC_ENABLED=true

ENV NEW_RELIC_ENABLED=$NEW_RELIC_ENABLED

RUN apk upgrade --no-cache && \
    rm -rf /tmp/* /var/cache/apk/* && \
    cd ~ && \
    export NEWRELIC_VERSION="newrelic-php5-12.12.0.41-linux-musl" && \
    curl -fsS "https://download.newrelic.com/php_agent/archive/12.12.0.41/${NEWRELIC_VERSION}.tar.gz" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION}" && \
    NR_INSTALL_SILENT=true NR_INSTALL_USE_CP_NOT_LN=true ./newrelic-install install && \
    cd .. && \
    unset NEWRELIC_VERSION

COPY newrelic.ini /usr/local/etc/php/conf.d/xx-newrelic.ini

COPY security.ini /usr/local/etc/php/conf.d/zz-security.ini
