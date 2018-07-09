FROM apluslms/service-base:python3-1.3

# Set container related configuration via environment variables
ENV CONTAINER_TYPE="aplus" \
    APLUS_LOCAL_SETTINGS="/srv/aplus-cont-settings.py" \
    APLUS_SECRET_KEY_FILE="/local/aplus/secret_key.py"

COPY rootfs /

RUN apt_install python3-pillow \
\
  # Create user
  && adduser --system --no-create-home --disabled-password --gecos "A+ webapp server,,," --home /srv/aplus --ingroup nogroup aplus \
  && mkdir /srv/aplus && chown aplus.nogroup /srv/aplus && cd /srv/aplus \
\
  # clone, touch local_settings to suppress warnings, prebuild .pyc files
  && git clone --quiet --single-branch https://github.com/Aalto-LeTech/a-plus.git . \
  && (echo "On branch $(git rev-parse --abbrev-ref HEAD) | $(git describe)"; echo; git log -n5) > GIT \
  && rm -rf .git \
  && python3 -m compileall -q . \
\
  # install requirements, remove the file, remove unrequired locales and tests
  && pip_install -r requirements.txt \
  && rm requirements.txt \
  && find /usr/local/lib/python* -type d -regex '.*/locale/[a-z_A-Z]+' -not -regex '.*/\(en\|fi\|sv\)' -print0 | xargs -0 rm -rf \
  && find /usr/local/lib/python* -type d -name 'tests' -print0 | xargs -0 rm -rf \
\
  # 3) preprocess
  && python3 manage.py compilemessages 2>&1 \
  && env APLUS_SECRET_KEY="dummy" create-django-db.sh aplus aplus /srv/aplus-setup.py


EXPOSE 8000
WORKDIR /srv/aplus
ENTRYPOINT [ "/init", "/srv/up.sh" ]
