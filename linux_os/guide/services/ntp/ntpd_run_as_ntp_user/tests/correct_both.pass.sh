#!/bin/bash

yum -y install ntp

echo 'OPTIONS="-u ntp:ntp"' > /etc/sysconfig/ntpd
echo 'ExecStart=/usr/sbin/ntpd -u ntp:ntp $OPTIONS' > /usr/lib/systemd/system/ntpd.service
