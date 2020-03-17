#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


yum -y install chrony

echo "pool 0.pool.ntp.org" > /etc/chrony.conf
