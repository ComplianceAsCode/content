#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_nist-800-171-cui
# remediation = bash

. ../delete_parameter.sh
delete_parameter /etc/audit/auditd.conf "space_left_action"
