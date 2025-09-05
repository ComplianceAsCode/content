#!/bin/bash
# packages = audit
# variables = var_auditd_admin_space_left_percentage=25

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "admin_space_left" "15%"
