#!/bin/bash

# platform = multi_platform_all
# packages = sudo

group_add sudoers

echo '%sudoers ALL=(ALL) TYPE=sysadm_t ROLE=sysadm_r ALL' >> /etc/sudoers.d/01-complianceascode.conf
