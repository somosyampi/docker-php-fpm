FROM php:7.1-fpm-alpine

WORKDIR /app

ENV TZ=UTC
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev libjpeg-turbo-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev libmcrypt-dev && \
    apk add --no-cache \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        --allow-untrusted \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium \
        libintl libzip-dev \
        icu shadow libmcrypt && \
    pecl install imagick && \
    pecl install -o -f redis && \
    pecl install -f libsodium && \
    docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-enable imagick redis && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd iconv intl mysqli \
        pdo pdo_mysql pcntl \
        soap tokenizer \
        xml zip intl \
        mcrypt mbstring && \
    apk del -f .build-deps && \
    cp "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini"

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
