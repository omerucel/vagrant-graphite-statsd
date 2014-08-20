#####################################
# General Configuration #
#####################################
SECRET_KEY = "aksdhaksdjhkasjdhkasjdhaksjdhksdjhakdjhaskdjhasdkj"
ALLOWED_HOSTS = [ '*' ]
TIME_ZONE = 'Europe/Istanbul'
DEBUG = True

#####################################
# Filesystem Paths #
#####################################
LOG_DIR = '/opt/graphite/storage/log/webapp/'

##########################
# Database Configuration #
##########################
DATABASES = {
    'default': {
        'NAME': 'graphite',
        'ENGINE': 'django.db.backends.mysql',
        'USER': 'graphite',
        'PASSWORD': 'graphite',
        'HOST': '',
        'PORT': ''
    }
}

from graphite.app_settings import *