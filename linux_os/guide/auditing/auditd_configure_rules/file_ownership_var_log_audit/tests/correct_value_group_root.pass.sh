#!/bin/bash
# packages = audit

source common.sh
sed -i '/^log_group.*$/d' /etc/audit/auditd.conf

touch "/var/log/audit/audit.log"
chgrp root -R "/var/log/audit/"
chown root -R "/var/log/audit/"
