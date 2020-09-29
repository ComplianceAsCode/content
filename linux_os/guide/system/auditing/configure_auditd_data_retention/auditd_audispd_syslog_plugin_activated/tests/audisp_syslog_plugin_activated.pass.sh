#!/bin/bash
# platform = Red Hat Enterprise Linux 7
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audisp/plugins.d/syslog.conf "active" "yes"
