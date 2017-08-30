#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

sed -i "/^kernel.randomize_va_space.*/d" /etc/sysctl.conf
