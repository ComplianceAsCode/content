#!/bin/bash
# packages = audit
# variables = var_auditd_disk_full_action=halt

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "disk_full_action"
