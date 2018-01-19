FROM apluslms/run-python3

# Required paths and tools
RUN mkdir -p /srv/a-plus /srv/data/aplus \
 && chmod 1777 /srv/data /srv/data/aplus
COPY up.sh test-bench-setup.py /srv/

# Install system packages
RUN apt-get update -qqy && DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
    -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    python3-pillow \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set container related configuration via environment variables
WORKDIR /srv/a-plus
ENV HOME=/srv/data \
    APLUS_DB_FILE=/srv/data/aplus.sqlite3 \
    APLUS_SECRET_KEY_FILE=/srv/data/aplus_secret_key.py
ENV APLUS_MEDIA_ROOT=/srv/data/aplus \
    DJANGO_CACHES="{\"default\": {\"BACKEND\": \"django.core.cache.backends.dummy.DummyCache\"}}" \
    APLUS_DATABASES="{\"default\": {\"ENGINE\": \"django.db.backends.sqlite3\", \"NAME\": \"$APLUS_DB_FILE\"}}" \
    APLUS_OVERRIDE_SUBMISSION_HOST="http://plus:8000"

# Install the application and requirements
#  1) clone, touch local_settings to suppress warnings, prebuild .pyc files
#  2) install requirements, remove the file, remove unrequired locales and tests
#  3) create database and fill with test environment info
RUN git clone https://github.com/Aalto-LeTech/a-plus.git . \
  && touch aplus/local_settings.py \
  && python3 -m compileall -q . \
\
  && pip3 --no-cache-dir --disable-pip-version-check install -r requirements.txt \
  && rm requirements.txt \
  && find /usr/local/lib/python* -type d -regex '.*/locale/[a-z_A-Z]+' -not -regex '.*/\(en\|fi\|sv\)' -print0 | xargs -0 rm -rf \
  && find /usr/local/lib/python* -type d -name 'tests' -print0 | xargs -0 rm -rf \
  && rm -rf /root/.cache \
\
  && python3 manage.py migrate \
  && python3 /srv/test-bench-setup.py \
  && chmod 0777 $APLUS_DB_FILE \
  && rm -rf $APLUS_SECRET_KEY_FILE

VOLUME /srv/data
EXPOSE 8000

ENTRYPOINT [ "/srv/up.sh" ]
