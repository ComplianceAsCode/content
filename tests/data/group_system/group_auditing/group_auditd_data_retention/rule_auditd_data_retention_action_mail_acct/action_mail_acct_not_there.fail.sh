#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

yum install -y audit

sed -i "/^action_mail_acct[[:space:]]*=/d" /etc/audit/auditd.conf
