#!/bin/bash
# platform = multi_platform_all

{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch /etc/sudoers
{{% endif %}}
echo "Defaults noexec" >> /etc/sudoers.d/enable_noexec
