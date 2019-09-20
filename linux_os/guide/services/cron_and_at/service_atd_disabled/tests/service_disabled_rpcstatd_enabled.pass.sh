#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp,xccdf_org.ssgproject.content_profile_standard

# this tesst ensures that only the atd.service is matched, not for example the service rpc-statd

yum -y install nfs-utils at
systemctl disable atd.service
systemctl add-wants default.target rpc-statd.service
