#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

. ../set_parameters_value.sh
set_parameters_value /etc/audit/auditd.conf "space_left" "250"
