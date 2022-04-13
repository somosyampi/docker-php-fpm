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
        --repository http://dl-3.alpinelinux.org/alpine/edge/testing \
        --allow-untrusted \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev \
        icu shadow libmcrypt && \
    pecl install imagick xdebug-2.5.0 && \
    pecl install -o -f redis && \
    pecl install -f libsodium && \
    docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-enable imagick redis xdebug && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd iconv intl mysqli \
        pdo pdo_mysql pcntl \
        soap tokenizer \
        xml zip intl \
        mcrypt mbstring && \
    apk del -f .build-deps && \
    cp "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini" && rm -rf /var/cache/* && rm -rf /tmp/* 

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo && composer clear-cache

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf
COPY docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
