#!/bin/bash
# platform = multi_platform_all

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter {{{ audisp_conf_path }}}/audisp-remote.conf "disk_full_action"
