#!/bin/bash
# packages = apparmor-utils

#Replace apparmor definitions
apparmor_parser -q -r /etc/apparmor.d/
#Set all profiles in enforce mode
{{% if 'ubuntu' in product %}}
find /etc/apparmor.d -maxdepth 1 ! -type d -exec aa-enforce "{}" \;
{{% else %}}
aa-enforce /etc/apparmor.d/*
{{% endif %}}

# rsyslogd apparmor profile is disabled in focal and jammy.
# Reloading the profile results in an unconfined process
# which fails the SCE, so we need to restart the process manually.
systemctl restart rsyslog

