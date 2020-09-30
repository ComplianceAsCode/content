#!/bin/bash
# 
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# We don't remediate anything if the config file is missing completely.
# remediation = none

yum install -y bind

BIND_CONF='/etc/named.conf'

rm -f "$BIND_CONF"
