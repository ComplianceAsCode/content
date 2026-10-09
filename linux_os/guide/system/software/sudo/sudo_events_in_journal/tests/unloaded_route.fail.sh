#!/bin/bash
# platform = Ubuntu 26.04
# packages = rsyslog,sudo-rs
# remediation = none

source include.sh
# Leave the drop-in on disk but remove the directive that loads it.
sed -i '/^\$IncludeConfig/d' /etc/rsyslog.conf
printf '%s\n' 'daemon.* /var/log/daemon.log' >> /etc/rsyslog.conf
systemctl restart rsyslog.service
