#!/bin/sh
set -e
# https://github.com/JeDaYoshi/docker-nextdns

# /etc/hosts usage is disabled by default to not
# have conflicts in regards to the container's name.
export NEXTDNS_USE_HOSTS="${NEXTDNS_USE_HOSTS:-false}"

CLI_ARGS="-setup-router=true"

while IFS="=" read -r var val; do
    if [[ "$var" = "NEXTDNS_PROFILE_"* ]]; then
        CLI_ARGS="$CLI_ARGS -profile=$val"
    elif [[ "$var" = "NEXTDNS_FORWARDER_"* ]]; then
        CLI_ARGS="$CLI_ARGS -forwarder=$val"
    elif [[ "$var" = "NEXTDNS_CONFIG" ]]; then
        echo "! NEXTDNS_CONFIG is deprecated. Please use NEXTDNS_PROFILE from now on"
        CLI_ARGS="$CLI_ARGS -profile=$val"
    elif [[ "$var" = "NEXTDNS_CONFIG_"* ]]; then
        echo "! NEXTDNS_CONFIG_<value> is deprecated. Please use NEXTDNS_PROFILE_<value> from now on"
        CLI_ARGS="$CLI_ARGS -profile=$val"
    else
        var=$(echo "$var" | cut -d "_" -f2- | tr "[:upper:]" "[:lower:]" | tr "_" "-")
        CLI_ARGS="$CLI_ARGS -$var=$val"
    fi
done < <(env | grep "NEXTDNS_")

echo "+ Running with arguments: $CLI_ARGS"
/usr/bin/nextdns run $CLI_ARGS
