#!/bin/bash
# packages = tripwire,linux-base
# platform = multi_platform_debian

echo "05 4 * * * root /usr/sbin/tripwire --check" >> /etc/crontab
