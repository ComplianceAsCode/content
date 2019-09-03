#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

# add read permission to /etc/shadow (default should be no perm. for everyone)
chmod +r /etc/shadow
