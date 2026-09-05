#!/bin/bash
# platform = Ubuntu 26.04
# packages = openssh-server

sed -ri '/^[[:space:]]*ClientAliveCountMax[[:space:]]+/Id' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null || true
