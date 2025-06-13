#!/bin/bash
# platform = multi_platform_ubuntu

source common.sh

echo "MACs $ssh_approved_macs" >> /etc/ssh/ssh_config.d/test.conf
