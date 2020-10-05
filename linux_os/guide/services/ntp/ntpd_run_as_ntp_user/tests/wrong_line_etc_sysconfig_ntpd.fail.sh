#!/bin/bash
# packages = ntp


echo 'OPTIONS="-u root:root"' > /etc/sysconfig/ntpd
rm -f /usr/lib/systemd/system/ntpd.service
