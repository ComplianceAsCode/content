#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/audisp-remote.conf "remote_server"
