#!/bin/bash
# platform = multi_platform_all
# packages = sudo

{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch /etc/sudoers
{{% endif %}}
echo "Defaults logfile=/var/log/sudo.log" >> /etc/sudoers.d/enable_logfile
