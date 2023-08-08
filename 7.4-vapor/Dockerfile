FROM laravelphp/vapor:php74

ARG NEW_RELIC_ENABLED=true

ENV NEW_RELIC_ENABLED=$NEW_RELIC_ENABLED

RUN cd ~ && \
    export NEWRELIC_VERSION="$(curl -sS https://download.newrelic.com/php_agent/release/ | sed -n "s/.*>\(.*linux-musl\).tar.gz<.*/\1/p")" && \
    curl -sS "https://download.newrelic.com/php_agent/release/${NEWRELIC_VERSION}.tar.gz" | gzip -dc | tar xf - && \
    cd "${NEWRELIC_VERSION}" && \
    NR_INSTALL_SILENT=true ./newrelic-install install && \
    cd .. && \
    unset NEWRELIC_VERSION && \
    sed -i \
        -e "s/;\?newrelic.enabled =.*/newrelic.enabled = \${NEW_RELIC_ENABLED}/" \
        -e "s/newrelic.license =.*/newrelic.license = \${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini
