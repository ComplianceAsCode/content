#!/bin/bash
# packages = audit
# profiles = xccdf_org.ssgproject.content_profile_cis

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "max_log_file_action" "keep_logs"
