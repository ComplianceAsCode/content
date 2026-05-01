#!/bin/bash
# platform = multi_platform_all
# packages = sudo

echo '%wheel ALL=(admin) ALL' > /etc/sudoers
echo 'user ALL=(admin) ALL' > /etc/sudoers.d/foo
{{% if product in [ 'sle16', 'slmicro6' ] %}}
sed -i "/^ALL[[:space:]]*ALL=(ALL)[[:space:]]*ALL/d" /usr/etc/sudoers
{{% endif %}}
