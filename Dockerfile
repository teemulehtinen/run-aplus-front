FROM apluslms/run-python3

# Required paths
RUN mkdir -p /srv/a-plus /srv/data/aplus \
 && chmod 1777 /srv/data /srv/data/aplus

# set WORKDIR to app location and HOME to world writable location
WORKDIR /srv/a-plus
ENV HOME /srv/data

# Install system packages
RUN apt-get update -qqy && apt-get install -qqy --no-install-recommends \
    -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    python3-pillow \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Copy tools used to start this container
COPY up.sh test-bench-setup.py /srv/

# Set container related configuration via environment variables
ENV APLUS_DB_FILE /srv/data/aplus.sqlite3
ENV APLUS_SECRET_KEY_FILE /srv/data/aplus_secret_key.py
ENV APLUS_MEDIA_ROOT /srv/data/aplus
ENV DJANGO_CACHES "{\"default\": {\"BACKEND\": \"django.core.cache.backends.dummy.DummyCache\"}}"
ENV APLUS_DATABASES "{\"default\": {\"ENGINE\": \"django.db.backends.sqlite3\", \"NAME\": \"$APLUS_DB_FILE\"}}"
ENV APLUS_OVERRIDE_SUBMISSION_HOST "http://plus:8000"

# Install the application and requirements
#  clone
#  suppress warnings about missing local_settings
#  prebuild python files (readonly code as normal user)
#  install requirements
#  rm requirements.txt (not required anymore and indicates that this is prod. version)
RUN git clone https://github.com/Aalto-LeTech/a-plus.git . \
  && touch aplus/local_settings.py \
  && python3 -m compileall -q . \
  && pip3 --no-cache-dir --disable-pip-version-check install -r requirements.txt \
  && rm requirements.txt \
  && rm -rf /root/.cache \
\
  && find /usr/local/lib/python* -path '*/locale/*/*' | grep -vE '/locale/(fi|en|sv)/' | xargs rm -rf \
  && find /usr/local/lib/python* -name 'tests' -a -type d -print0 | xargs -0 rm -rf \
\
  && python3 manage.py migrate \
  && python3 /srv/test-bench-setup.py \
  && chmod 0777 $APLUS_DB_FILE \
  && rm -rf $APLUS_SECRET_KEY_FILE


VOLUME /srv/data
EXPOSE 8000

ENTRYPOINT [ "/srv/up.sh" ]
