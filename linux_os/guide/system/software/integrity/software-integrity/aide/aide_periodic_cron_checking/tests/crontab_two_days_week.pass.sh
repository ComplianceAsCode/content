#!/bin/bash
# packages = aide,crontabs

echo '21    21    *    *    1-2    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
