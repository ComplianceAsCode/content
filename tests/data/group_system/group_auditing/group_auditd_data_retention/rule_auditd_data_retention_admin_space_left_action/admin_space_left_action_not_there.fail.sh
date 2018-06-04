#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

. ../delete_parameter.sh
delete_parameter /etc/audit/auditd.conf "admin_space_left_action"
