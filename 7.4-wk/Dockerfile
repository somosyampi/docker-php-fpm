FROM ubuntu:focal

WORKDIR /app

ENV TZ=UTC

ADD https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y gnupg zip unzip git && mkdir -p ~/.gnupg && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ppa_ondrej_php.list && \
    apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C && \
    apt-get update && apt-get install -y \
        fontconfig libxrender1 xfonts-75dpi xfonts-base\
        php7.4-fpm php7.4-cli \
        php7.4-sqlite3 php7.4-gd \
        php7.4-curl php7.4-imap php7.4-mysql \
        php7.4-mbstring php7.4-xml php7.4-zip \
        php7.4-bcmath php7.4-soap php7.4-intl \
        php7.4-readline php7.4-msgpack \
        php7.4-igbinary php7.4-redis && \
    dpkg -i /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb && rm /tmp/wkhtmltox_0.12.6-1.focal_amd64.deb && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /src && \
    ln -s /usr/sbin/php-fpm7.4 /usr/local/bin/php-fpm && \
    mkdir -p /run/php

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo

COPY 99-yampi.ini /etc/php/7.4/fpm/conf.d/99-yampi.ini
COPY 99-www.conf /etc/php/7.4/fpm/pool.d/www.conf

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
