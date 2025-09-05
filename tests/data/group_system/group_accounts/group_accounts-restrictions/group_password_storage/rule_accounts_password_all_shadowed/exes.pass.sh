#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_pci-dss

sed -i 's/^\([^:]*\):\*:/\1:x:/' /etc/passwd
