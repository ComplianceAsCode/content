#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "max_log_file"
