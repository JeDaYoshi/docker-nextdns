#!/bin/sh
# https://github.com/JeDaYoshi/docker-nextdns
set -e

# By default I'd rather disable reading from /etc/hosts,
# to not have conflicts in regards to the container's name.
export NEXTDNS_USE_HOSTS="${NEXTDNS_USE_HOSTS:-false}"

CLI_ARGS="-setup-router=true"

while IFS="=" read -r var val; do
    if [[ "$var" = "NEXTDNS_CONFIG_"* ]]; then
        CLI_ARGS="$CLI_ARGS -config=$val"
    elif [[ "$var" = "NEXTDNS_FORWARDER_"* ]]; then
        CLI_ARGS="$CLI_ARGS -forwarder=$val"
    else
    	var=$(echo "$var" | cut -d "_" -f2- | tr "[:upper:]" "[:lower:]" | tr "_" "-")
    	CLI_ARGS="$CLI_ARGS -$var=$val"
    fi
done < <(env | grep "NEXTDNS_")

echo "+ Running with arguments: $CLI_ARGS"
/usr/bin/nextdns run $CLI_ARGS
