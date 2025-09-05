#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Red Hat Enterprise Linux 7

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "max_log_file_action" "rotate"
