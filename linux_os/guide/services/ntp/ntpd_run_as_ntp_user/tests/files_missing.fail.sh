#!/bin/bash

yum -y install ntp

rm -f /etc/sysconfig/ntpd
rm -f /usr/lib/systemd/system/ntpd.service
