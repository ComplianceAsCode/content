#!/bin/bash
#
# packages = aide

echo '@weekly    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
