#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

sed -i "/^UsePrivilegeSeparation.*/d" /etc/ssh/sshd_config
