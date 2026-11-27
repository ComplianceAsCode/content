#!/bin/bash
# packages = sudo
echo "Defaults authenticate" > /etc/sudoers

mkdir -p /etc/sudoers.d
echo "Defaults !authenticate" >> /etc/sudoers.d/sudoers
