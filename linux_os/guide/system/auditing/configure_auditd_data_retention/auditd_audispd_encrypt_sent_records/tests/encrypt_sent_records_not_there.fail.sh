#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter {{{ audisp_conf_path }}}/audisp-remote.conf "enable_krb5"
