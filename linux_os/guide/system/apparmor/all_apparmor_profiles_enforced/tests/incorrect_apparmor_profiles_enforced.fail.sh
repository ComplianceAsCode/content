#!/bin/bash
# packages = apparmor-utils

#Replace apparmor definitions and force profiles into compliant mode
apparmor_parser -q -r  /etc/apparmor.d/ 
#Set all profiles in complain mode
aa-complain /etc/apparmor.d/*

# rsyslogd apparmor profile is disabled in focal and jammy.
# Reloading the profile results in an unconfined process
# which fails the SCE, so we need to restart the process manually.
systemctl restart rsyslog
