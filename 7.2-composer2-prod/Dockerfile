# Agente New Relic fixo por arquitetura: no bump, os ARGs de cada uma mudam juntos.
# arm64: compilado do fonte com o patch do wraprec, daemon do pacote da mesma versão.
ARG NEWRELIC_VERSION=12.12.0.41
ARG NEWRELIC_COMMIT=cf77822cd783c43cf3f8bb2acc1caa22c49e23cb
ARG NEWRELIC_SHA256=b93a0f11dc9a65ae8ca992dc8edd8db756591eccbdb74308f744840acde4e24f
# amd64: binário oficial, sem o patch. A 12.12.0.41 oficial resolve funções para o
# wrapper errado em worker CLI longo no PHP < 7.4, então o amd64 fica na 12.10.0.39.
ARG NEWRELIC_AMD64_VERSION=12.10.0.39
ARG NEWRELIC_AMD64_SHA256=2da47eb5135a548f2876e22d3e2fb097c696ea145e1cd7f67c96925084f614d2

FROM php:7.2-fpm-alpine AS newrelic-arm64

ARG TARGETARCH
ARG NEWRELIC_VERSION
ARG NEWRELIC_COMMIT

COPY newrelic-agent-wraprec-16bit.patch /nr-patch/newrelic-agent-wraprec-16bit.patch

# O pacote oficial do agente New Relic só traz o binário aarch64 para PHP 8.0+.
# Em arm64 o agente é compilado do código-fonte no commit fixado acima, e o
# daemon vem do pacote oficial dessa mesma versão. Em amd64 este estágio não faz nada.
# O patch evita o estouro do índice de wraprec (16 bits) em worker CLI longo no PHP < 7.4.
RUN mkdir -p /out && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        apk add --no-cache $PHPIZE_DEPS bash git pcre-dev protobuf-c-dev && \
        git init -q /src && \
        git -C /src fetch -q --depth 1 https://github.com/newrelic/newrelic-php-agent.git "${NEWRELIC_COMMIT}" && \
        git -C /src checkout -q FETCH_HEAD && \
        test "$(cat /src/VERSION).${NEWRELIC_VERSION##*.}" = "${NEWRELIC_VERSION}" && \
        git -C /src apply /nr-patch/newrelic-agent-wraprec-16bit.patch && \
        make -C /src -j"$(nproc)" agent OPTIMIZE=1 BUILD_NUMBER="${NEWRELIC_VERSION##*.}" && \
        cp /src/agent/modules/newrelic.so /out/newrelic.so; \
    fi

FROM php:7.2-fpm-alpine

ARG TARGETARCH
ARG NEWRELIC_VERSION
ARG NEWRELIC_SHA256
ARG NEWRELIC_AMD64_VERSION
ARG NEWRELIC_AMD64_SHA256

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
    if [ "$TARGETARCH" = "amd64" ]; then \
        NEWRELIC_VERSION="${NEWRELIC_AMD64_VERSION}" && \
        NEWRELIC_SHA256="${NEWRELIC_AMD64_SHA256}"; \
    fi && \
    NEWRELIC_PKG="newrelic-php5-${NEWRELIC_VERSION}-linux-musl" && \
    curl -fsS -o "${NEWRELIC_PKG}.tar.gz" \
        "https://download.newrelic.com/php_agent/archive/${NEWRELIC_VERSION}/${NEWRELIC_PKG}.tar.gz" && \
    echo "${NEWRELIC_SHA256}  ${NEWRELIC_PKG}.tar.gz" | sha256sum -c - && \
    tar xzf "${NEWRELIC_PKG}.tar.gz" && \
    rm -f "${NEWRELIC_PKG}.tar.gz" && \
    cd "${NEWRELIC_PKG}" && \
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

RUN php -d newrelic.enabled=0 -m | grep -qx newrelic && \
    if [ "$TARGETARCH" = "amd64" ]; then expected="${NEWRELIC_AMD64_VERSION}"; else expected="${NEWRELIC_VERSION}"; fi && \
    test "$(php -d newrelic.enabled=0 -r 'echo phpversion("newrelic");')" = "${expected}"

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
