#!/bin/bash
# packages = audit
#
# remediation = bash
# profiles = xccdf_org.ssgproject.content_profile_cis

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "admin_space_left_action" "email"
