#!/bin/bash
# packages = aide,crontabs

{{{ bash_package_remove("aide") }}}

echo '21    21    *    *    *    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
