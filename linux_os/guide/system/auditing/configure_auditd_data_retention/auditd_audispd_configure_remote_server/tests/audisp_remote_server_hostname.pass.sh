#!/bin/bash
# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_ospp42

. $SHARED/auditd_utils.sh
prepare_auditd_test_enviroment
set_parameters_value /etc/audisp/audisp-remote.conf "remote_server" "myhost.mydomain.com"
