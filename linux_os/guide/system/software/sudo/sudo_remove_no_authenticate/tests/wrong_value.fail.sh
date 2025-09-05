#!/bin/bash

echo "Defaults !authenticate" >> /etc/sudoers
chmod 440 /etc/sudoers

mkdir /etc/sudoers.d/
echo "Defaults !authenticate" >> /etc/sudoers.d/sudoers
chmod 440 /etc/sudoers.d/sudoers
