FROM ubuntu:18.04

WORKDIR /app

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y gnupg zip unzip git && mkdir -p ~/.gnupg && \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ppa_ondrej_php.list && \
    apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C && \
    apt-get update && apt-get install -y \
        php5.6-fpm php5.6-cli php5.6-mcrypt \
        php5.6-sqlite3 php5.6-gd \
        php5.6-curl php5.6-imap php5.6-mysql \
        php5.6-mbstring php5.6-xml php5.6-zip \
        php5.6-bcmath php5.6-soap php5.6-intl \
        php5.6-readline php5.6-msgpack \
        php5.6-igbinary php5.6-redis && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /src && \
    ln -s /usr/sbin/php-fpm5.6 /usr/local/bin/php-fpm && \
    mkdir -p /run/php

COPY --from=composer:1 /usr/bin/composer /usr/local/bin/composer
RUN composer global require hirak/prestissimo

COPY 99-yampi.ini /etc/php/5.6/fpm/conf.d/99-yampi.ini
COPY 99-www.conf /etc/php/5.6/fpm/pool.d/www.conf

CMD ["php-fpm", "--allow-to-run-as-root", "--nodaemonize"]
