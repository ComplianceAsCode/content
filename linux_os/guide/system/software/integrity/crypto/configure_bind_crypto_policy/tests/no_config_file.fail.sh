#!/bin/bash
# packages = bind
# 
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# We don't remediate anything if the config file is missing completely.
# remediation = none


BIND_CONF='/etc/named.conf'

rm -f "$BIND_CONF"
