#!/bin/bash

yum -y install ntp

echo "" > /etc/sysconfig/ntpd
echo "" > /usr/lib/systemd/system/ntpd.service
