#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis

# CIS only requires the content matches the site policy, but doesn't accept exposure of OS technical information.
echo "CIS doesn't require a specific content, considering there is no technical information about the system." > /etc/issue.net
