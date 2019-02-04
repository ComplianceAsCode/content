#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_nist-800-171-cui, xccdf_org.ssgproject.content_profile_ospp
# remediation = bash

. set-up-pamd.sh

set-up-pamd
rm -f /etc/pam.d/system-auth
