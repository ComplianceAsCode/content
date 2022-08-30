#!/bin/bash
# packages = firewalld
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

# ensure firewalld installed
# put rule into wrong chain
firewall-cmd --permanent --direct --add-rule ipv4 filter OUTPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j INPUT_ZONES
firewall-cmd --reload
