#!/bin/bash
# packages = audit
# platform = Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_cis

echo "-w /var/run/faillock  -p w" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
