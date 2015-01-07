#! /bin/sh

###
#
# A very basic init.d script. It will do for a start, but needs improvement.
#
### BEGIN INIT INFO
# Provides: carbon-cache
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: init script for carbon-cache
# Description: init script for carbon-cache; should be copied to /etc/init.d
### END INIT INFO

GRAPHITE_HOME=/opt/graphite
CARBON_USER=www-data

case "$1" in
    start)
        echo "Starting script carbon-cache"
        su $CARBON_USER -s /bin/bash -c "cd $GRAPHITE_HOME"; \
            su $CARBON_USER -s /bin/bash -c "$GRAPHITE_HOME/bin/carbon-cache.py start"
        touch /var/lock/carbon-cache
        ;;
    stop)
        echo "Stopping script carbon-cache"
        su $CARBON_USER -s /bin/bash -c "cd $GRAPHITE_HOME"; \
            su $CARBON_USER -s /bin/bash -c "$GRAPHITE_HOME/bin/carbon-cache.py stop"
        rm -f /var/lock/carbon-cache
        ;;
    status)
        test -f /var/lock/carbon-cache && echo "carbon-cache is running"
        test ! -f /var/lock/carbon-cache && echo "carbon-cache is not running"
        ;;
    *)
        echo "Usage: /etc/init.d/carbon-cache {start|stop|status}"
        exit 1
        ;;
esac

exit 0
