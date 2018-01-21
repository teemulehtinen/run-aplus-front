#!/bin/sh -e

db=$APLUS_DB_FILE

# Check for development mount -> install updated requirements to venv (no root perms)
if [ -e "requirements.txt" ]; then
    python3 -m virtualenv -p python3 --system-site-packages /srv/data/aplus_venv
    . /srv/data/aplus_venv/bin/activate
    pip3 install --disable-pip-version-check -r requirements.txt
    [ "$db" -a -e "$db" ] && python3 manage.py migrate
fi

# make sure some data paths exists
mkdir -p "$APLUS_MEDIA_ROOT"

if [ "$1" = "manage" ]; then
    shift
    exec python3 manage.py "$@"
elif [ "$1" ]; then
    exec "$@"
else
    # Create database if one doesn't exists
    if [ "$db" -a ! -e "$db" ]; then
        python3 manage.py migrate
        python3 /srv/test-bench-setup.py
    fi

    python3 manage.py reload_course_configuration def/current || true
    exec python3 manage.py runserver 0.0.0.0:8000
fi
