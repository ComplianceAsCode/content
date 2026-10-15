#!/bin/bash
# packages = sudo
mkdir -p /etc/sudoers.d
echo "Defaults:%wheel env_reset,!authenticate" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
