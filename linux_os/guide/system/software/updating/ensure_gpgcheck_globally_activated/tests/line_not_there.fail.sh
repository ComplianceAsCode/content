#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i "/^gpgcheck.*/d" /etc/yum.conf
