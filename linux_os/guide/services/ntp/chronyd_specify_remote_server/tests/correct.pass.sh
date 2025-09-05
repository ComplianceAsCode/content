#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


yum -y install chrony

echo "server 0.pool.ntp.org" > /etc/chrony.conf
