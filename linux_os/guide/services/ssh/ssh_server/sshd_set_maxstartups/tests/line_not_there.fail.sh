#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_cis

sed -i "/^MaxStartups.*/d" /etc/ssh/sshd_config
