FROM php:8.3-fpm-alpine

WORKDIR /app

ENV TZ=UTC

RUN apk upgrade --no-cache && \
    apk add --no-cache --update --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev libjpeg-turbo-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev linux-headers && \
    apk add --no-cache --update \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev \
        icu shadow && \
    pecl install xdebug && \
    pecl install -o -f redis && \
    git clone \
            https://github.com/Imagick/imagick.git \
            /usr/src/php/ext/imagick && \
    docker-php-ext-configure gd \
        --with-jpeg=/usr/lib \
        --with-freetype=/usr/include/freetype2 && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd intl mysqli \
        pdo pdo_mysql pcntl \
        soap xml zip \
        imagick sodium && \
    docker-php-ext-enable imagick redis xdebug && \
    apk del -f .build-deps && \
    rm -rf /tmp/* /var/cache/apk/* && \
    cp "/usr/local/etc/php/php.ini-development" "/usr/local/etc/php/php.ini"

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf
COPY docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
