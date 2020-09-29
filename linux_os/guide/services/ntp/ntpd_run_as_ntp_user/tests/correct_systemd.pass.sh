#!/bin/bash
# packages = ntp


echo 'ExecStart=/usr/sbin/ntpd -u ntp:ntp $OPTIONS' > /usr/lib/systemd/system/ntpd.service
rm -f /etc/sysconfig/ntpd
