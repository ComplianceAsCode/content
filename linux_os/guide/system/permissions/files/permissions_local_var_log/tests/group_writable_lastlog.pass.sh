#!/bin/bash
# platform = SUSE Linux Enterprise 15
find /var/log -type f -exec chmod 640 {} +

mkdir -p /var/log/testme
touch /var/log/testme/lastlog
chmod 660 /var/log/testme/lastlog
