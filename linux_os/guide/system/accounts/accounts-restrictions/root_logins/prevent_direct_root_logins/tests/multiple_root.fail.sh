#!/bin/bash
# packages = passwd
# platform = multi_platform_all
# remediation = none

echo "root:newpassword" | chpasswd

echo 'root:*:20115:0:99999:7:::' >> /etc/shadow
