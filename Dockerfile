FROM apluslms/run-python3

RUN apt-get update && apt-get install -y --no-install-recommends \
      python3-pillow \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv

RUN git clone https://github.com/Aalto-LeTech/a-plus.git .

ADD local_settings.py .
ADD test-bench-setup.py ./course/management/commands/test-bench-setup.py

RUN pip3 install -r requirements.txt \
  && mkdir -p media \
  && mkdir -p /db \
  && python3 manage.py migrate \
  && python3 manage.py test-bench-setup

VOLUME /db
EXPOSE 8000

ENTRYPOINT ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
