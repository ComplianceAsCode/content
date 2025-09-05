#!/bin/bash
# packages = firewalld
# platform = Red Hat Enterprise Linux 7,multi_platform_wrlinux

# ensure firewalld installed
# put rule into wrong chain
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES
firewall-cmd --reload
