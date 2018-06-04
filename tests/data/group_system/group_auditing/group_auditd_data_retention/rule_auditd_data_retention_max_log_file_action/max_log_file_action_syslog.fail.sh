#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. ../set_parameters_value.sh
set_parameters_value /etc/audit/auditd.conf "max_log_file_action" "syslog"
