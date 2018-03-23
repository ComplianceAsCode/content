#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = none

SSSD_CONF="/etc/sssd/sssd.conf"
cp wrong_sssd.conf $SSSD_CONF
