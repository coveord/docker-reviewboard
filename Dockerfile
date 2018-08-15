# Docker user: jenkins
# Name: reviewboard
# Build order: 1
# Folders to ignore: .git

# Strongly inspired by https://github.com/ikatson/docker-reviewboard

FROM python:2.7.15
MAINTAINER dblanchette@coveo.com

ARG RB_VERSION
RUN apt-get update && apt-get install --no-install-recommends  -y \
    build-essential \
    default-libmysqlclient-dev \
    git-core \
    libffi-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libssl-dev patch \
    memcached \
    python-dev \
    python-ldap \
    uwsgi \
    uwsgi-plugin-python \
 && rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    if [ "${RB_VERSION}" ]; then RB_VERSION="==${RB_VERSION}"; fi; \
    python -m virtualenv --system-site-packages /opt/venv; \
    . /opt/venv/bin/activate; \
    pip install "ReviewBoard${RB_VERSION}" 'django-storages<1.3' semver python-ldap \
    mercurial python-memcached mysql-python ReviewBoard; \
    rm -rf /root/.cache

ENV PATH="/opt/venv/bin:${PATH}"

RUN mkdir -p /app/reviewboard
ADD start.sh /app/reviewboard/start.sh
ADD uwsgi.ini /app/reviewboard/uwsgi.ini
ADD upgrade-site.py /app/reviewboard/upgrade-site.py

RUN chmod +x /app/reviewboard/start.sh /app/reviewboard/upgrade-site.py

VOLUME /var/www/

EXPOSE 80

CMD /app/reviewboard/start.sh