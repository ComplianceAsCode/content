#!/bin/bash
# platform = SUSE Linux Enterprise 16
source common.sh

echo "DenyUsers user" >> /usr/etc/ssh/sshd_config.d/01-complianceascode-reinforce-os-defaults.conf
