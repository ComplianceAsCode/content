#!/bin/bash
# packages = ntp


echo 'OPTIONS="-u ntpsec:ntpsec"' > /etc/systemd/system/ntpd.service
echo 'NTPD_OPTS="$NTPD_OPTS -u ntpsec:ntpsec"' > /usr/libexec/ntpsec/ntp-systemd-wrapper
