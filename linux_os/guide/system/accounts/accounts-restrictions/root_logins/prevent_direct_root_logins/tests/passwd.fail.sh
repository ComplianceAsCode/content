#!/bin/bash
# packages = passwd
# platform = multi_platform_all
# remediation = none

echo "root:newpassword" | chpasswd
