#!/bin/bash
# platform = Red Hat Enterprise Linux 7

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audisp/audisp-remote.conf "remote_server"
