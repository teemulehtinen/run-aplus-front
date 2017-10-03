#!/bin/bash

python3 manage.py test-bench-configure
python3 manage.py runserver 0.0.0.0:8000
