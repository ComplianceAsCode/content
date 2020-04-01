#!/bin/bash

yum -y install ntp

echo "" > /etc/sysconfig/ntpd
rm -f /usr/lib/systemd/system/ntpd.service
