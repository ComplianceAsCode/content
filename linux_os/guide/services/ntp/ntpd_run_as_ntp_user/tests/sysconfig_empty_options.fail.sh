#!/bin/bash
# packages = ntp


echo 'OPTIONS=""' > /etc/systemd/system/ntpd.service
rm -f /usr/libexec/ntpsec/ntp-systemd-wrapper
