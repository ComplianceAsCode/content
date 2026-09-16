#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

mkdir -p /etc/cron.d
echo "05 4 * * * root /usr/sbin/tripwire --check" > /etc/cron.d/tripwire-check
