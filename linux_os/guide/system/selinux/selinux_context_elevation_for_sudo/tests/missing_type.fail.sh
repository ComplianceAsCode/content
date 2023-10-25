#!/bin/bash

# platform = multi_platform_all
# packages = sudo
# remediation = none

echo '%wheel ALL=(ALL) ROLE=sysadm_r ALL' >> /etc/sudoers.d/01-complianceascode.conf
