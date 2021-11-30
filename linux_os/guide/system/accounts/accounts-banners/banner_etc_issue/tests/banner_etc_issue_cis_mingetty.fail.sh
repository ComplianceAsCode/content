#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis, xccdf_org.ssgproject.content_profile_cis_server_l1, xccdf_org.ssgproject.content_profile_cis_workstation_l1, xccdf_org.ssgproject.content_profile_cis_workstation_l2

# CIS doesn't have an explicit content required, but doesn't expect technical information about the OS.
echo "Sytem name \s version \s " > /etc/issue
