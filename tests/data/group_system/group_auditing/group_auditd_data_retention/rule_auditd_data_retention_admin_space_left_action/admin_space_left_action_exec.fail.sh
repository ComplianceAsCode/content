#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

. ../set_parameters_value.sh
set_parameters_value /etc/audit/auditd.conf "admin_space_left_action" "exec /path-to-script"
