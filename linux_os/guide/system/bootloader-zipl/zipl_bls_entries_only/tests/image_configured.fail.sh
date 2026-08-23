#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# remediation = none

# Make sure no image configured in zipl config file
echo 'image = /boot/image' >> /etc/zipl.conf
