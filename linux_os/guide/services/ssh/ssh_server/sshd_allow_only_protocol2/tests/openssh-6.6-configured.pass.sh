#!/bin/bash
#

# Test targeted to RHEL 7.4
yum downgrade -y openssh-6.6.1p1 openssh-clients-6.6.1p1 openssh-server-6.6.1p1

echo "Protocol 2" >> /etc/ssh/sshd_config
