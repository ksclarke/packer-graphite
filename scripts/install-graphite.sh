#! /bin/bash

# Install dependencies needed for our Graphite installation
sudo apt-get install -y apache2-mpm-prefork libapache2-mod-wsgi python-cairo python2.7 python-memcache
sudo apt-get install -y python-django python-django-tagging python-ldap python-simplejson python-setuptools
sudo apt-get install -y  python-txamqp python-rrdtool python-pip

# Install Graphite (and related) packages
sudo pip install https://github.com/graphite-project/ceres/tarball/master
sudo pip install whisper
sudo pip install carbon
sudo pip install graphite-web
sudo pip install daemonize

# Change Graphite ownership to the user running the installation script (so we can easily make the changes below)
sudo chown -R ubuntu:ubuntu /opt/graphite

# Configure core Graphite applications
cd /opt/graphite/conf
cp carbon.conf.example carbon.conf
cp storage-schemas.conf.example storage-schemas.conf
cp graphite.wsgi.example graphite.wsgi

# Configure the Graphite Web application
GRAPHITE_SETTINGS_FILE=/opt/graphite/webapp/graphite/local_settings.py
cp /opt/graphite/webapp/graphite/local_settings.py.example $GRAPHITE_SETTINGS_FILE

# Put a symlink to the Graphite logs in the expected /var/log location
sudo ln -s /opt/graphite/storage/log/webapp /var/log/graphite

# Configure local_settings.py to add SECRET_KEY, logging section, and database config
printf "\n\nSECRET_KEY = '$GRAPHITE_SECRET_KEY'" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\nLOG_RENDERING_PERFORMANCE = True" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\nLOG_CACHE_PERFORMANCE = True" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\nLOG_METRIC_ACCESS = True" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n\nDATABASES = {" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n  'default': {" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'NAME': '/opt/graphite/storage/graphite.db'," | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'ENGINE': 'django.db.backends.sqlite3'," | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'USER': 'graphiteAdmin'," | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'PASSWORD': '$GRAPHITE_ADMIN_PASSWORD'," | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'HOST': ''," | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n    'PORT': ''" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n  }" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null
printf "\n}" | sudo tee -a $GRAPHITE_SETTINGS_FILE >/dev/null

# Create the Graphite database and initialize the super user account
cd /opt/graphite/webapp/graphite
sudo python manage.py syncdb --noinput
DJSU_SCRIPT="from django.contrib.auth.models import User; User.objects.create_superuser"
DJSU_SCRIPT="$DJSU_SCRIPT('graphiteAdmin', '$SERVER_ADMIN_EMAIL', '$GRAPHITE_ADMIN_PASSWORD')"
echo $DJSU_SCRIPT | sudo python manage.py shell

# Fix some incompatibilities between Django 1.6 (used by our OS) and Graphite 0.9.10
DAEMONIZE_RE_PATTERN="s/from twisted.scripts._twistd_unix import daemonize/import daemonize/"
DJANGO_URLS_RE_PATTERN="s/from django.conf.urls.defaults import/from django.conf.urls import/"
sudo sed -i -e "$DAEMONIZE_RE_PATTERN" /opt/graphite/lib/carbon/util.py
find /opt/graphite/webapp/graphite -type f -print0 | xargs -0 sudo sed -i "$DJANGO_URLS_RE_PATTERN"
