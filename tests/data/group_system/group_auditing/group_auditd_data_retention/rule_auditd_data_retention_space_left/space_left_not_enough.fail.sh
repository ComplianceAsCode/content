#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

sed -i "s/^space_left[[:space:]]*=.*$/space_left = 15/" /etc/audit/auditd.conf
