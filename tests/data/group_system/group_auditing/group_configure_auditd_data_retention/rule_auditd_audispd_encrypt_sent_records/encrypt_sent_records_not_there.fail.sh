#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa, xccdf_org.ssgproject.content_profile_ospp

. ../../auditd_utils.sh
prepare_auditd_test_enviroment
delete_parameter /etc/audisp/audisp-remote.conf "enable_krb5"
