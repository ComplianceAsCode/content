#!/bin/bash
# remediation = none
# platform = multi_platform_all

sed -i '/Include/d' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf
