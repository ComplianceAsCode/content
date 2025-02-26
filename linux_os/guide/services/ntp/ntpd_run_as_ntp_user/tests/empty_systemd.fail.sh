#!/bin/bash
# packages = ntp


echo "" > /usr/libexec/ntpsec/ntp-systemd-wrapper
rm -f /etc/systemd/system/ntpd.service
