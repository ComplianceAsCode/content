#!/bin/bash
# packages = ntp


echo "" > /etc/systemd/system/ntpd.service
rm -f /usr/libexec/ntpsec/ntp-systemd-wrapper
