#!/bin/bash
# packages = aide,crontabs

echo '21    21    *    *    *    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
