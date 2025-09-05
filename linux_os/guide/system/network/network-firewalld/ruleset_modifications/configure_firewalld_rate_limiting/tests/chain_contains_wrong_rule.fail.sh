#!/bin/bash
# packages = firewalld
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7


# ensure firewalld installed
# add wrong rule
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -p tcp -m limit --limit 25/minute --limit-burst 100  -j ACCEPT
firewall-cmd --reload
