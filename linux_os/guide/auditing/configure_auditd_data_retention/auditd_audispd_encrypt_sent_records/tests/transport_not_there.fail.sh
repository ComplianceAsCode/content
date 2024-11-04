#!/bin/bash
# packages = audit
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,SUSE Linux Enterprise 15

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/audisp-remote.conf "transport"
