#!/bin/bash
# platform = multi_platform_sle
source common.sh

echo "MACs ${sshd_approved_macs}" >> /etc/ssh/sshd_config
echo "MACs weak-hmac" >> /etc/ssh/sshd_config
