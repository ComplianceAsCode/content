#!/bin/bash
# packages = ntp


echo 'NTPD_OPTS="$NTPD_OPTS -u root:root"' > /usr/libexec/ntpsec/ntp-systemd-wrapper
rm -f /etc/systemd/system/ntpd.wrapper
