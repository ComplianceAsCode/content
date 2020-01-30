#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_wrlinux

# ensure firewalld installed
yum install -y firewalld
# put rule into wrong chain
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES
firewall-cmd --reload
