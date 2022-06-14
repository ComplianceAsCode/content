#!/bin/bash
# packages = audit
# variables = var_auditd_disk_error_action=halt

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "disk_error_action" "syslog"
