#!/bin/bash
# packages = audit
# variables = var_auditd_max_log_file_action=syslog

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "max_log_file_action" "syslog"
