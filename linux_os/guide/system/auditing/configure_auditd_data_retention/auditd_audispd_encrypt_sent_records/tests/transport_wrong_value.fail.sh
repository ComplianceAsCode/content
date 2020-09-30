#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/audisp-remote.conf "transport" "TCP"
