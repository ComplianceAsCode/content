#!/bin/bash
# packages = dconf
# platform = multi_platform_opensuse,multi_platform_ubuntu

rm -f /etc/dconf/profile/gdm
{{% if product not in ['opensuse16', 'sle15', 'sle16'] %}}
rm -f /etc/dconf/profile/user
{{% endif %}}
