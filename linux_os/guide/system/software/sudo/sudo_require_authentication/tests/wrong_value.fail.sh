#!/bin/bash

echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
echo "Defaults !authenticate" >> /etc/sudoers
chmod 440 /etc/sudoers

mkdir /etc/sudoers.d/
echo "%wheel        ALL=(ALL)       !authenticate ALL" >> /etc/sudoers.d/sudoers
echo "Defaults !authenticate" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
