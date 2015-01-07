#! /bin/bash

# Hack the Ubuntu Landscape login message to add our custom information
sudo apt-get remove -y --purge landscape-client
sudo rm -f /etc/update-motd.d/51-cloudguest
sudo tee $(sudo find /usr/lib -name landscapelink.py) > /dev/null <<EOF

from twisted.internet.defer import succeed

class LandscapeLink(object):
  def register(self, sysinfo):
    self._sysinfo = sysinfo
  def run(self):
    self._sysinfo.add_footnote(
      "This is a Graphite server (built with Packer.io)\n    Learn more at ${PACKER_GRAPHITE_REPO}")
    return succeed(None)

EOF