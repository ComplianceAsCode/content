#!/bin/bash
# packages = sudo
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
chmod 440 /etc/sudoers
