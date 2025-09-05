#!/bin/bash
# packages = aide,crontabs

echo '@weekly    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
