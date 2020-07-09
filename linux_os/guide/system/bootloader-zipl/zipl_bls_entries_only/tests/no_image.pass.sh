#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# remediation = none

# Make sure no image configured in zipl config file
sed -Ei '/^image\s*=/d' /etc/zipl.conf
true
