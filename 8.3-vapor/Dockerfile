FROM laravelphp/vapor:php83

ARG NEW_RELIC_ENABLED=true

ENV NEW_RELIC_ENABLED=$NEW_RELIC_ENABLED

RUN cd ~ && \
    export NEWRELIC_VERSION="$(curl -sS https://download.newrelic.com/php_agent/release/ | sed -n "s/.*>\(.*linux-musl\).tar.gz<.*/\1/p")" && \
    curl -sS "https://download.newrelic.com/php_agent/release/${NEWRELIC_VERSION}.tar.gz" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION}" && \
    NR_INSTALL_SILENT=true NR_INSTALL_USE_CP_NOT_LN=true ./newrelic-install install && \
    cd .. && \
    unset NEWRELIC_VERSION

COPY newrelic.ini /usr/local/etc/php/conf.d/xx-newrelic.ini
