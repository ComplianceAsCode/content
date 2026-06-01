#!/bin/bash

# packages = logrotate,crontabs

{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults('/usr/etc/logrotate.conf', '/etc/logrotate.conf') }}}
{{% endif %}}

sed -i "/^\s*(daily|weekly|monthly|yearly)/d" /etc/logrotate.conf
rm -f /etc/cron.daily/logrotate
