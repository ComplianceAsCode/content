#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

. $SHARED/sysctl.sh

sysctl_set_kernel_setting_to dmesg_restrict 0
