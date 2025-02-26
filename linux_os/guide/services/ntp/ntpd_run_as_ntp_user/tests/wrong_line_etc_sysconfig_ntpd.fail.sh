#!/bin/bash
# packages = ntp


echo 'OPTIONS="-u root:root"' > /etc/systemd/system/ntpd.service
rm -f /usr/libexec/ntpsec/ntp-systemd-wrapper
