#!/bin/bash
# packages = sudo
echo "%wheel	ALL=(ALL)	ALL" > /etc/sudoers
chmod 440 /etc/sudoers

mkdir -p /etc/sudoers.d
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
