#! /bin/bash

# Start the basic system installation; put in a stupid loop to work around Ubuntu mirror issues
for ATTEMPT in 1 2 3; do
  sudo apt-get update -y --fix-missing
  sudo unattended-upgrade
  sudo apt-get install -ym nano htop nmap

  if [ ! -z "`which nano`" ] && [ ! -z "`which htop`"  ] && [ ! -z "`which nmap`"  ]; then
    break
  fi
done