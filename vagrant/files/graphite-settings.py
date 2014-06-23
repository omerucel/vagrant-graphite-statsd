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
LOG_DIR = '/vagrant/log/'

##########################
# Database Configuration #
##########################
DATABASES = {
    'default': {
        'NAME': 'graphite',
        'ENGINE': 'django.db.backends.mysql',
        'USER': 'root',
        'PASSWORD': '',
        'HOST': '',
        'PORT': ''
    }
}

from graphite.app_settings import *