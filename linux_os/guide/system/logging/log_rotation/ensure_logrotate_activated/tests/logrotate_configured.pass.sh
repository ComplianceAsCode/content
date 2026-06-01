#!/bin/bash

# platform = Oracle Linux 7,Oracle Linux 8,SUSE Linux Enterprise 16

{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults('/usr/etc/logrotate.conf', '/etc/logrotate.conf') }}}
{{% endif %}}
# fix logrotate config
sed -i "s/\(weekly\|monthly\|yearly\)/daily/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
