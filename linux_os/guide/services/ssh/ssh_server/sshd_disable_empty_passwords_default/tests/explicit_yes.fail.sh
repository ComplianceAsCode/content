#!/bin/bash
# platform = Ubuntu 26.04
# packages = openssh-server

mkdir -p /etc/ssh/sshd_config.d
echo 'PermitEmptyPasswords yes' > /etc/ssh/sshd_config.d/00-cis-test.conf
