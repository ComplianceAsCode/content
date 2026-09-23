#!/bin/bash
# packages = sudo

rm -f /etc/sudoers
echo "Defaults authenticate" > /etc/sudoers
chmod 440 /etc/sudoers
