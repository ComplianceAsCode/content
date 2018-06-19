#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

. ../../auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audisp/audisp-remote.conf "remote_server" "10.10.10.10"
