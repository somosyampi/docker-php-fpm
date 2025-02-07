FROM phpswoole/swoole:5.1-php8.3

WORKDIR /app

# Environment variables
ENV TZ=UTC
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_UPLOAD_MAX_FILESIZE=10M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256M
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=10000
ENV PHP_OPCACHE_JIT_BUFFER_SIZE=128M

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git unzip curl dnsutils \
        libicu-dev libjpeg-dev libpng-dev \
        libfreetype6-dev libxml2-dev \
        libzip-dev libsodium-dev imagemagick \
        libmagickwand-dev libgmp-dev \
        awscli jq && \
    git clone \
        https://github.com/Imagick/imagick.git \
        /usr/src/php/ext/imagick && \
    docker-php-ext-configure gd \
        --with-jpeg \
        --with-freetype && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd intl mysqli \
        pdo pdo_mysql pcntl \
        soap xml zip \
        imagick sodium && \
    docker-php-ext-enable imagick gd && \
    apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Copy PHP configuration files
COPY yampi.ini /usr/local/etc/php/conf.d/zz-yampi.ini
COPY opcache.ini /usr/local/etc/php/conf.d/zz-opcache-recommended.ini
