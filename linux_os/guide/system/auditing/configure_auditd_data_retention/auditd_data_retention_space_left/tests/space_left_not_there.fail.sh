#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "space_left"
