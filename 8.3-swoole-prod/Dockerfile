FROM phpswoole/swoole:5.1-php8.3-alpine

WORKDIR /app

ENV TZ=UTC
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_UPLOAD_MAX_FILESIZE=10M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256M
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=10000
ENV PHP_OPCACHE_JIT_BUFFER_SIZE=128M

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
        icu shadow aws-cli jq && \
    git clone \
        https://github.com/Imagick/imagick.git \
        /usr/src/php/ext/imagick && \
    docker-php-ext-configure gd \
        --with-jpeg=/usr/lib \
        --with-freetype=/usr/include/freetype2 && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd intl mysqli \
        pdo pdo_mysql pcntl \
        soap xml zip \
        imagick sodium && \
    docker-php-ext-enable imagick gd && \
    apk del -f .build-deps && \
    docker-php-source delete && \
    rm -rf /tmp/* /var/cache/apk/* && \
    cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini"

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY yampi.ini /usr/local/etc/php/conf.d/zz-yampi.ini
COPY opcache.ini /usr/local/etc/php/conf.d/zz-opcache-recommended.ini
