#!/bin/bash
# packages = audit
#
# profiles = xccdf_org.ssgproject.content_profile_cis
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "admin_space_left_action" "halt"
