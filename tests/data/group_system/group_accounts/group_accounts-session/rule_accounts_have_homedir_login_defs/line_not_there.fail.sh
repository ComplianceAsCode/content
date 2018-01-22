#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = none

sed -i "/.*CREATE_HOME.*/d" /etc/login.defs
