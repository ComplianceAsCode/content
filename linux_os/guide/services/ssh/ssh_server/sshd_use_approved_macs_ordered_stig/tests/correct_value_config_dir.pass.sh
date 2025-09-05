#!/bin/bash
# platform = multi_platform_ubuntu

source common.sh

echo "MACs $sshd_approved_macs" >> /etc/ssh/sshd_config.d/test.conf
