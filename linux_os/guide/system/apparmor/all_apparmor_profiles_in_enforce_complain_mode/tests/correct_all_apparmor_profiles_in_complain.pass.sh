#!/bin/bash
# packages = apparmor-utils

#Replace apparmor definitions
apparmor_parser -q -r /etc/apparmor.d/
{{% if 'ubuntu' in product %}}
# Set all profiles to complain mode except disabled profiles
find /etc/apparmor.d -maxdepth 1 ! -type d -exec bash -c '[[ -e "/etc/apparmor.d/disable/$(basename "{}")" ]] || aa-complain "{}"' \;
{{% else %}}
#Set all profiles in complain mode
aa-complain /etc/apparmor.d/*
{{% endif %}}

