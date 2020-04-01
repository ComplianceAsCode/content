#!/bin/bash

yum -y install ntp

echo 'OPTIONS=""' > /etc/sysconfig/ntpd
rm -f /usr/lib/systemd/system/ntpd.service
