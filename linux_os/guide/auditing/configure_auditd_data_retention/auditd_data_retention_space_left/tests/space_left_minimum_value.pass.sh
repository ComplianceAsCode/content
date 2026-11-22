#!/bin/bash
# packages = audit
# profiles = stig

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "space_left" "100"
