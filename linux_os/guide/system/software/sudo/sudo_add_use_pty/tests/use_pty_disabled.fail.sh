#!/bin/bash
# platform = multi_platform_all
# packages = sudo

sed '/Defaults.*use_pty/ s/.*/#&/g' -i /etc/sudoers /etc/sudoers.d/*
echo "Defaults !use_pty" >> /etc/sudoers.d/enable_use_pty
