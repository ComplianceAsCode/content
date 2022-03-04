#!/bin/bash

{{{ bash_sysctl_test_clean() }}}

sed -i "/net.ipv4.conf.default.accept_source_route/d" /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_source_route = 1" >> /run/sysctl.d/run.conf
# Setting correct runtime value
sysctl -w net.ipv4.conf.default.accept_source_route=0
