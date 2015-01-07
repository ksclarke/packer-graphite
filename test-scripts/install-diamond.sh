#! /bin/bash

# Install Diamond's dependencies and useful related tools
sudo apt-get install -y libxml2-utils make pbuilder python-mock python-configobj python-support cdbs

# TODO: Upgrade this to https://github.com/python-diamond/Diamond (?)
git clone https://github.com/BrightcoveOS/Diamond.git
cd Diamond
git checkout 3a7ec2cd89e1f623df3d06a4e1569473edd26ff4
make builddeb
sudo dpkg -i build/diamond_3.5.0_all.deb

# Go ahead and configure it while we're still in the Diamond directory
sudo mkdir -p /etc/diamond
sudo cp conf/diamond.conf.example /etc/diamond/diamond.conf
