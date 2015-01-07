#! /bin/bash

# Install Supervisor
sudo apt-get install -y supervisor

# Install Supervisor's configuration file
sudo tee /etc/supervisor/supervisord.conf > /dev/null <<'CONFIG_EOF'

[unix_http_server]
file=/var/run/supervisor.sock
chmod=0700

[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
childlogdir=/var/log/supervisor

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[include]
files=/etc/supervisor/conf.d/*.conf

[program:apache]
command=/usr/sbin/apache2ctl -D FOREGROUND
autostart=true
autorestart=true

[program:carbon]
user=www-data
directory=/opt/graphite
; --debug is required for this version of Carbon because Supervisor expects the program to run in the foreground
; --nodaemon will work with the version of Carbon that is in the master GitHub branch [TODO: Upgrade to that?]
command=/usr/bin/python /opt/graphite/bin/carbon-cache.py --debug start
autostart=true
autorestart=true
environment=HOME="/var/www", USER="www-data", SHELL="/usr/sbin/nologin"

CONFIG_EOF

#
# docker run -p 127.0.0.1:80:80 127.0.0.1:2003:2003 -t -i $(docker images -q | head -1) /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
#