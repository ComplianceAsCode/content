#!/bin/bash
# packages = audit
# variables = var_auditd_admin_space_left_percentage=25

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "admin_space_left"
