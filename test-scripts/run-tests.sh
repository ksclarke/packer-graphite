#! /bin/bash

MAX_ATTEMPTS=10
SUCCESSFUL=false

# Check that we have stress installed, since we depend on it
hash stress 2>/dev/null || { echo >&2 "I require the program stress but it's not installed. Aborting."; exit 1; }

# Check that the basic Graphite Web UI is up and responding
for TRY in $(seq 1 $MAX_ATTEMPTS); do
  stress --cpu 2 --timeout 120s

  if [[ $(wget -q -O - "$1" | xmllint --html --xpath "//title" -) == "<title>Graphite Browser</title>" ]]; then
    SUCCESSFUL=true
    break
  else
    echo "Failed attempt (#${TRY}) to query the Graphite Web UI at ${1}; trying again..."
  fi
done

if [ "$SUCCESSFUL" = false ]; then
  exit 1
else
  SUCCESSFUL=false
fi

# Check that the Carbon-Cache endpoint for Graphite is up and receiving metrics
for TRY in $(seq 1 $MAX_ATTEMPTS); do
  stress --cpu 2 --timeout 60s

  if [[ $(wget -q -O - "$1/render?target=carbon.agents.*.cpuUsage&format=csv" | grep -c -) -gt 5 ]]; then
    SUCCESSFUL=true
    break
  else
    echo "Failed attempt (#${TRY}) to post to Graphite's Carbon-Cache interface at ${1}; trying again..."
  fi
done

if [ "$SUCCESSFUL" = false ]; then
  exit 1
fi
