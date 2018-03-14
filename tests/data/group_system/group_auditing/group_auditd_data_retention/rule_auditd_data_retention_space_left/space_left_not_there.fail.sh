#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

sed -i "/^space_left = /d" /etc/audit/auditd.conf
