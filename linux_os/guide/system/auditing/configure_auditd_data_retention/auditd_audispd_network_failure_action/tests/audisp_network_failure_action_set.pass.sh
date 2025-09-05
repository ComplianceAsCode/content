#!/bin/bash
# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value {{{ audisp_conf_path }}}/audisp-remote.conf "network_failure_action" "single"
