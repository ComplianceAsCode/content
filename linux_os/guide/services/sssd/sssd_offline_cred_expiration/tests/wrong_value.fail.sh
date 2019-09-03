#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

source common.sh

echo -e "[pam]\noffline_credentials_expiration = 0" >> $SSSD_CONF
