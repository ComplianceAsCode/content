#!/bin/bash
#
# packages = aide

echo '21    21    *    *    3    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
