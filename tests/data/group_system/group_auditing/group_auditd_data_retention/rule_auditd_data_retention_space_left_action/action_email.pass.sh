#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

sed -i "s/^space_left_action = .*$/space_left_action = email/" /etc/audit/auditd.conf
