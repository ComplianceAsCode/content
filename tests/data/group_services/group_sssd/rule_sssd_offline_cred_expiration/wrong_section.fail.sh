#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

source common.sh

echo -e "[pam]\ntest = 1" >> $SSSD_CONF
echo -e "[sssd]\noffline_credentials_expiration = 1" >> $SSSD_CONF
