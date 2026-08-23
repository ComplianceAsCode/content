#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis

# CIS doesn't have an explicit content required, but doesn't expect OS IDs, like rhel.
echo "This system is rhel." > /etc/issue.net
