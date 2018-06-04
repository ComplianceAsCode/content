#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

yum install -y audit

ACTION_MAIL_ACCT_REGEX="^action_mail_acct[[:space:]]*=.*$"
if grep -q "$ACTION_MAIL_ACCT_REGEX" /etc/audit/auditd.conf; then
        sed -i "s/^action_mail_acct[[:space:]]*=.*$/action_mail_acct = root/" /etc/audit/auditd.conf
else
        echo "action_mail_acct = root" >> /etc/audit/auditd.conf
fi
