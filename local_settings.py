import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/db/db.sqlite3',
    }
}

if not os.environ.get('APLUS_TEST_CACHE'):
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
        }
    }

OVERRIDE_SUBMISSION_HOST = 'http://plus:8000'
