#!/bin/bash
# packages = sudo
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
