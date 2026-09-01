#!/bin/sh

set -e -a

php artisan optimize --force
php artisan config:cache
php artisan route:cache

php-fpm --allow-to-run-as-root --nodaemonize
