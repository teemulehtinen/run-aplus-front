#!/usr/bin/with-contenv /bin/sh
set -eu

cd /srv/aplus

# Use python from virtualenv if present
[ -e "/local/venv_aplus/bin/activate" ] && . /local/venv_aplus/bin/activate

# Ensure database state
init-django-db.sh aplus aplus /srv/test-bench-setup.py

# With dev code, we need to rerun few init tasks
if [ -e requirements.txt ]; then
    python3 manage.py compilemessages -v0
fi
setuidgid aplus python3 manage.py collectstatic --noinput -v0

# Start background services/tasks
#start_services
# start course updater (will exit when successful)
run_services aplus-course-update

# Execute main script
if [ "${1:-}" = "manage" ]; then
    shift
    exec setuidgid aplus python3 manage.py "$@"
elif [ "${1:-}" ]; then
    exec setuidgid aplus "$@"
else
    exec setuidgid aplus python3 manage.py runserver 0.0.0.0:8000
fi
