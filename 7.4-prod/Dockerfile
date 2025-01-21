FROM php:7.4-fpm-alpine3.13

WORKDIR /app

ENV TZ=UTC

ENV PHP_MEMORY_LIMIT=256M
ENV PHP_UPLOAD_MAX_FILESIZE=10M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256M
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=10000

ARG NEW_RELIC_ENABLED=true
ENV NEW_RELIC_ENABLED=$NEW_RELIC_ENABLED

RUN apk upgrade --no-cache && \
    apk add --no-cache --update --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev libjpeg-turbo-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev && \
    apk add --no-cache --update \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev \
        icu shadow && \
    pecl install imagick && \
    pecl install -o -f redis && \
    pecl install -f libsodium && \
    docker-php-ext-configure gd \
        --with-jpeg=/usr/lib \
        --with-freetype=/usr/include/freetype2 && \
    docker-php-ext-enable imagick redis opcache && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd iconv intl mysqli \
        pdo pdo_mysql pcntl \
        soap tokenizer \
        xml zip intl && \
    apk del -f .build-deps && \
    cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini" && \
    cd ~ && \
    export NEWRELIC_VERSION="$(curl -sS https://download.newrelic.com/php_agent/release/ | sed -n "s/.*>\(.*linux-musl\).tar.gz<.*/\1/p")" && \
    curl -sS "https://download.newrelic.com/php_agent/release/${NEWRELIC_VERSION}.tar.gz" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION}" && \
    NR_INSTALL_SILENT=true NR_INSTALL_USE_CP_NOT_LN=true ./newrelic-install install && \
    cd .. && \
    unset NEWRELIC_VERSION

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
