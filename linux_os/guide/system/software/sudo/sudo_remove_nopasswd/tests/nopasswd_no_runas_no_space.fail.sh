#!/bin/bash
# packages = sudo
mkdir -p /etc/sudoers.d
echo "%wheel ALL=NOPASSWD: ALL" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
