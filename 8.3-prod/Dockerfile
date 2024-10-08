FROM php:8.3-fpm-alpine

WORKDIR /app

ENV TZ=UTC

RUN apk upgrade --no-cache && \
    apk add --no-cache --update --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev && \
    apk add --no-cache --update \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev libjpeg-turbo-dev \
        icu shadow gmp-dev && \
    pecl install -o -f redis && \
    git clone \
            https://github.com/Imagick/imagick.git \
            /usr/src/php/ext/imagick && \
    docker-php-ext-configure gd \
        --with-jpeg=/usr/lib \
        --with-freetype=/usr/include/freetype2 && \
    docker-php-ext-configure opcache --enable-opcache &&\
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd intl mysqli \
        pdo pdo_mysql pcntl \
        soap opcache xml \
        zip imagick sodium gmp && \
    docker-php-ext-enable imagick redis && \
    apk del -f .build-deps && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/cache/apk/* && \
    cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini"

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf
COPY opcache.ini /usr/local/etc/php/conf.d/05-opcache-recommended.ini

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
