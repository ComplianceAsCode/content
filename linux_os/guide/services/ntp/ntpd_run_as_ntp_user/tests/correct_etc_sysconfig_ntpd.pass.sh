#!/bin/bash
# packages = ntp


echo 'OPTIONS="-u ntpsec:ntpsec"' > /etc/systemd/system/ntpd.service
rm -f /usr/libexec/ntpsec/ntp-systemd-wrapper
