#! /bin/bash

#
# A script to reconfigure Apache so that it serves up Graphite's Web UI.
#

sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null <<CONFIG_EOF

WSGISocketPrefix /var/run/wsgi

<VirtualHost *:80>

       ServerAdmin $SERVER_ADMIN_EMAIL

       ServerName graphite
       DocumentRoot "/opt/graphite/webapp"

       ErrorLog /opt/graphite/storage/log/webapp/error.log
       CustomLog /opt/graphite/storage/log/webapp/access.log common

       WSGIDaemonProcess graphite processes=5 threads=5 display-name='%{GROUP}' inactivity-timeout=120
       WSGIProcessGroup graphite
       WSGIApplicationGroup %{GLOBAL}
       WSGIImportScript /opt/graphite/conf/graphite.wsgi process-group=graphite application-group=%{GLOBAL}
       WSGIScriptAlias / /opt/graphite/conf/graphite.wsgi

       Alias /content/ /opt/graphite/webapp/content/
       <Location "/content/">
               SetHandler None
               Order deny,allow
               Allow from all
       </Location>
       <Directory /opt/graphite/conf/>
               Options All
               AllowOverride All
               Require all granted
       </Directory>
       <Directory /opt/graphite/webapp>
               Options All
               AllowOverride All
               Require all granted
       </Directory>

</VirtualHost>

CONFIG_EOF

 # Make Graphite's storage directory writeable by the Web server
sudo chown -R www-data:www-data /opt/graphite/storage

# Restart Apache to pick up on the configuration change
sudo service apache2 restart