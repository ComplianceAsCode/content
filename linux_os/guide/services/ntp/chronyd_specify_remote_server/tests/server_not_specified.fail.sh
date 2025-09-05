#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

yum -y install chrony

echo "server " > /etc/chrony.conf
