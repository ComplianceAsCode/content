#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

sed -i "/.*CREATE_HOME.*/d" /etc/login.defs
