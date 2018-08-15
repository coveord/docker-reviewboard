#!/bin/bash

DOMAIN="$( echo "${DOMAIN:-0.0.0.0}" )"

if [[ "${SITE_ROOT}" ]]; then
    if [[ "${SITE_ROOT}" != "/" ]]; then
        # Add trailing and leading slashes to SITE_ROOT if it's not there.
        SITE_ROOT="${SITE_ROOT#/}"
        SITE_ROOT="/${SITE_ROOT%/}/"
    fi
else
    SITE_ROOT=/
fi

MYSQL_DB="$( echo "${MYSQL_DB:-reviewboard}" )"
MYSQL_HOST="$( echo "${MYSQL_HOST:-localhost}" )"
MYSQL_PORT="$( echo "${MYSQL_PORT:-3306}" )"
MYSQL_USER="$( echo "${MYSQL_USER:-reviewboard}" )"
MYSQL_PASSWORD="$( echo "${MYSQL_PASSWORD:-reviewboard}" )"

$MEMCACHED_PORT="$( echo "${MEMCACHED_PORT:-11211}" )"

mkdir -p /var/www/

CONFFILE=/var/www/reviewboard/conf/settings_local.py

if [[ ! -d /var/www/reviewboard ]]; then
    rb-site install --noinput \
        --domain-name="${DOMAIN}" \
        --site-root="$SITE_ROOT" \
        --static-url=static/ --media-url=media/ \
        --db-type=mysql \
        --db-name="$MYSQL_DB" \
        --db-host="$MYSQL_HOST:$MYSQL_PORT" \
        --db-user="$MYSQL_USER" \
        --db-pass="$MYSQL_PASSWORD" \
        --cache-type=memcached --cache-info="$MEMCACHED_ENDPOINT:$MEMCACHED_PORT" \
        --web-server-type=lighttpd --web-server-port=80 \
        --admin-user=admin --admin-password=admin --admin-email=admin@example.com \
        /var/www/reviewboard/
fi

/app/reviewboard/upgrade-site.py /var/www/reviewboard/rb-version /var/www/reviewboard

if [[ "${DEBUG}" ]]; then
    sed -i 's/DEBUG *= *False/DEBUG=True/' "$CONFFILE"
    cat "${CONFFILE}"
fi

export SITE_ROOT

exec uwsgi --ini /app/reviewboard/uwsgi.ini