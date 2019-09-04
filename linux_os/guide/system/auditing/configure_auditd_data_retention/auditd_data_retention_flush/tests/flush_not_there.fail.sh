#!/bin/bash
# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audit/auditd.conf "flush"
