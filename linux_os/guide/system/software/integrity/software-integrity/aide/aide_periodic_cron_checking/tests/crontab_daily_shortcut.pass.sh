#!/bin/bash
# packages = aide,crontabs

echo '@daily    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
