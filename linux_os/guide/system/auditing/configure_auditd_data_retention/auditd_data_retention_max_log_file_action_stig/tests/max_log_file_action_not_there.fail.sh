#!/bin/bash
# packages = audit
# variables = var_auditd_max_log_file_action=syslog

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "max_log_file_action"
