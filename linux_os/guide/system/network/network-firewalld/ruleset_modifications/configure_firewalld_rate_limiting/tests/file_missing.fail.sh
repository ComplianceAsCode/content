#!/bin/bash
# platform = Red Hat Enterprise Linux 7,multi_platform_wrlinux


# ensure firewalld installed
yum install -y firewalld

rm -f /etc/firewalld/direct.xml
