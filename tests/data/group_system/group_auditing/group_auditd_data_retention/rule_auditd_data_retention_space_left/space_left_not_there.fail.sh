#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

. ../delete_parameter.sh
delete_parameter /etc/audit/auditd.conf "space_left"
