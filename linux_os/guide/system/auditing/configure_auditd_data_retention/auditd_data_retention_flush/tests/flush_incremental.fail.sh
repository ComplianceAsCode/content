#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audit/auditd.conf "flush" "incremental"
