#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

if grep -q "^CREATE_HOME" /etc/login.defs; then
	sed -i "s/^CREATE_HOME.*/CREATE_HOME no/" /etc/login.defs
else
	echo "CREATE_HOME no" >> /etc/login.defs
fi
