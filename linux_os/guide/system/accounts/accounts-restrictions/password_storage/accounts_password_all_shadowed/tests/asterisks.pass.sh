#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

sed -i 's/^\([^:]*\):x:/\1:\*:/' /etc/passwd
