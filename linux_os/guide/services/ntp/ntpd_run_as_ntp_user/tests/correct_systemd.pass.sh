#!/bin/bash
# packages = ntp


echo 'NTPD_OPTS="$NTPD_OPTS -u ntpsec:ntpsec"' > /usr/libexec/ntpsec/ntp-systemd-wrapper
rm -f /etc/systemd/system/ntpd.service
