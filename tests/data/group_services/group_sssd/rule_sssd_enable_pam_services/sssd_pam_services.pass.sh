#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

SSSD_PAM_SERVICES_REGEX="^[\s]*\[sssd]([^\n]*\n+)+?[\s]*services.*pam.*$"
SSSD_PAM_SERVICES="[sssd]
services = pam"
SSSD_CONF="/etc/sssd/sssd.conf"

grep -q "$SSSD_PAM_SERVICES_REGEX" $SSSD_CONF && \
	sed -i "s/$SSSD_PAM_SERVICES_REGEX/$SSD_PAM_SERVICES/" $SSSD_CONF || \
	echo "$SSSD_PAM_SERVICES" >> $SSSD_CONF
