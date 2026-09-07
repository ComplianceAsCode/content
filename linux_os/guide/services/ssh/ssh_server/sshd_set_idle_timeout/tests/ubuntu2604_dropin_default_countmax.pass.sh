#!/bin/bash
# platform = Ubuntu 26.04
# packages = openssh-server

mkdir -p /etc/ssh/sshd_config.d
sed -ri '/^[[:space:]]*ClientAlive(Interval|CountMax)[[:space:]]+/Id' \
    /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null || true
echo 'ClientAliveInterval 300' > /etc/ssh/sshd_config.d/00-cis-test.conf
