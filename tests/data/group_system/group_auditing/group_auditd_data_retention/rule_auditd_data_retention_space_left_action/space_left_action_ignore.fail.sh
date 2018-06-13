#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_nist-800-171-cui
# remediation = bash

. ../set_parameters_value.sh
set_parameters_value /etc/audit/auditd.conf "space_left_action" "ignore"
