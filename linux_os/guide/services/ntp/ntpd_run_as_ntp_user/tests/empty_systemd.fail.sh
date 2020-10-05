#!/bin/bash
# packages = ntp


echo "" > /usr/lib/systemd/system/ntpd.service
rm -f /etc/sysconfig/ntpd
