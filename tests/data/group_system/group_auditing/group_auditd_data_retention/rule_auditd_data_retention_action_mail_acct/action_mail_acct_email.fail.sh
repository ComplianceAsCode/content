#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

. ../set_parameters_value.sh
set_parameters_value /etc/audit/auditd.conf "action_mail_acct" "some@email.com"
