#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i "/^MaxStartups.*/d" /etc/ssh/sshd_config
