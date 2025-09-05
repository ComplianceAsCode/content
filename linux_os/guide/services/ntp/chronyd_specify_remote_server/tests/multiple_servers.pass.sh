#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8


echo "server 0.pool.ntp.org" > /etc/chrony.conf
echo "server 1.pool.ntp.org" >> /etc/chrony.conf
