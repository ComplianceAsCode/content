#!/bin/bash
# platform = Ubuntu 26.04
# packages = openssh-server

mkdir -p /etc/ssh/sshd_config.d
echo 'KexAlgorithms -diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1' > /etc/ssh/sshd_config.d/00-cis-test.conf
