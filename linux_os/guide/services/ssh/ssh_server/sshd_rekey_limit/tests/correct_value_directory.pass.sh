#!/bin/bash
# platform = multi_platform_all
# variables = var_rekey_limit_size=900M,var_rekey_limit_time=3h


mkdir -p /etc/ssh/sshd_config.d

sed -i '/^\s*RekeyLimit\b/Id' /etc/ssh/sshd_config
echo "RekeyLimit 900M 3h" >> /etc/ssh/sshd_config.d/good_config.conf
