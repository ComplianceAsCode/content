#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

. ../delete_parameter.sh
delete_parameter /etc/audit/auditd.conf "max_log_file_action"
