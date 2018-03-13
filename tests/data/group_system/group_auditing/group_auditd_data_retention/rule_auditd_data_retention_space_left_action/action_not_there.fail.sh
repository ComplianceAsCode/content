#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

sed -i "/^space_left_action = /d" /etc/audit/auditd.conf
