FROM php:7.2-fpm-alpine AS newrelic-arm64

ARG TARGETARCH
ARG NEWRELIC_ARM64_VERSION=12.12.0.41

COPY newrelic-agent-wraprec-16bit.patch /nr-patch/newrelic-agent-wraprec-16bit.patch

# O pacote oficial do agente New Relic só traz o binário aarch64 para PHP 8.0+.
# Em arm64 o agente é compilado do código-fonte na versão fixada acima, e o
# daemon vem do pacote oficial dessa mesma versão. Em amd64 este estágio não faz nada.
# O patch evita o estouro do índice de wraprec (16 bits) em worker CLI longo no PHP < 7.4.
RUN mkdir -p /out && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        apk add --no-cache $PHPIZE_DEPS bash git pcre-dev protobuf-c-dev && \
        git clone --depth 1 --branch "v${NEWRELIC_ARM64_VERSION}" \
            https://github.com/newrelic/newrelic-php-agent.git /src && \
        git -C /src apply /nr-patch/newrelic-agent-wraprec-16bit.patch && \
        make -C /src -j"$(nproc)" agent OPTIMIZE=1 BUILD_NUMBER="${NEWRELIC_ARM64_VERSION##*.}" && \
        cp /src/agent/modules/newrelic.so /out/newrelic.so && \
        echo "${NEWRELIC_ARM64_VERSION}" > /out/VERSION; \
    fi

FROM php:7.2-fpm-alpine

WORKDIR /app

ENV TZ=UTC

ENV PHP_MEMORY_LIMIT=512M
ENV PHP_UPLOAD_MAX_FILESIZE=10M
ENV PHP_POST_MAX_SIZE=10M
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256M
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=10000

ARG NEW_RELIC_ENABLED=true
ENV NEW_RELIC_ENABLED=$NEW_RELIC_ENABLED

RUN --mount=type=bind,from=newrelic-arm64,source=/out,target=/tmp/newrelic-arm64 \
    apk upgrade --no-cache && \
    apk add --no-cache --update --virtual .build-deps \
        $PHPIZE_DEPS curl-dev freetype-dev \
        icu-dev imagemagick-dev libjpeg-turbo-dev \
        libpng-dev libsodium-dev libtool \
        libxml2-dev sqlite-dev && \
    apk add --no-cache --update \
        bind-tools curl git gnu-libiconv \
        imagemagick libsodium libgomp \
        libintl libzip-dev pcre \
        icu shadow && \
    pear update-channels && \
    pecl update-channels && \
    pecl install imagick timezonedb && \
    pecl install -o -f redis-6.0.2 && \
    pecl install -f libsodium && \
    docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-enable imagick redis opcache timezonedb && \
    docker-php-ext-install -j$(nproc) \
        bcmath curl exif \
        gd iconv intl mysqli \
        pdo pdo_mysql pcntl \
        soap tokenizer \
        xml zip intl && \
    apk del -f .build-deps && \
    cp "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini" && \
    cd ~ && \
    if [ -f /tmp/newrelic-arm64/VERSION ]; then \
        NEWRELIC_RELEASE="$(cat /tmp/newrelic-arm64/VERSION)" && \
        export NEWRELIC_VERSION="newrelic-php5-${NEWRELIC_RELEASE}-linux-musl" && \
        export NEWRELIC_URL="https://download.newrelic.com/php_agent/archive/${NEWRELIC_RELEASE}/${NEWRELIC_VERSION}.tar.gz"; \
    else \
        export NEWRELIC_VERSION="$(curl -sS https://download.newrelic.com/php_agent/release/ | sed -n "s/.*>\(.*linux-musl\).tar.gz<.*/\1/p")" && \
        export NEWRELIC_URL="https://download.newrelic.com/php_agent/release/${NEWRELIC_VERSION}.tar.gz"; \
    fi && \
    curl -fsS "${NEWRELIC_URL}" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION}" && \
    NR_INSTALL_SILENT=true NR_INSTALL_USE_CP_NOT_LN=true ./newrelic-install install && \
    if [ -f /tmp/newrelic-arm64/newrelic.so ]; then \
        install -m 0755 /tmp/newrelic-arm64/newrelic.so "$(php-config --extension-dir)/newrelic.so" && \
        cp scripts/newrelic.ini.template "${PHP_INI_DIR}/conf.d/newrelic.ini"; \
    fi

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY www.conf /usr/local/etc/php-fpm.d/zz-www.conf
COPY yampi.ini /usr/local/etc/php-fpm.d/zz-yampi.ini
COPY yampi.ini /usr/local/etc/php/conf.d/zz-yampi.ini
COPY opcache.ini /usr/local/etc/php/conf.d/zz-opcache-recommended.ini
COPY newrelic.ini /usr/local/etc/php/conf.d/zz-newrelic.ini

RUN php -d newrelic.enabled=0 -m | grep -qx newrelic

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
