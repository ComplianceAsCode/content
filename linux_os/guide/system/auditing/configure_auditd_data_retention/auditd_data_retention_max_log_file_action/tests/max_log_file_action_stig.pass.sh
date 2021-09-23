#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9, multi_platform_fedora

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "max_log_file_action" "syslog"
