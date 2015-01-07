#! /bin/bash

 # Start the data collector to confirm it's working
sudo -u www-data /usr/bin/python /opt/graphite/bin/carbon-cache.py start

# TODO: Include a simple test here

# Move the init.d script, which the file provisioner left in /tmp, into its place
sudo mv /tmp/carbon-cache /etc/init.d/carbon-cache

# Make sure carbon-cache init.d script starts when the system (re)starts
sudo chown root:root /etc/init.d/carbon-cache
sudo chmod 755 /etc/init.d/carbon-cache
sudo update-rc.d carbon-cache defaults