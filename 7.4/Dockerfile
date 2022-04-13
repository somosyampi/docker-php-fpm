FROM php:7.4-fpm-alpine3.13

WORKDIR /app

ENV TZ=UTC

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev libjpeg-turbo-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev && \
    apk add --no-cache \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev \
        icu shadow && \
    pecl install imagick mongodb && \
    pecl install -o -f redis && \
    pecl install -f libsodium && \
    docker-php-ext-configure gd \
        --with-jpeg=/usr/lib \
        --with-freetype=/usr/include/freetype2 && \
    docker-php-ext-enable imagick mongodb redis && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd iconv intl mysqli \
        pdo pdo_mysql pcntl \
        soap tokenizer \
        xml zip intl && \
    apk del -f .build-deps && \
    cp "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini" && rm -rf /var/cache/* && rm -rf /tmp/*

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo && composer clear-cache

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
