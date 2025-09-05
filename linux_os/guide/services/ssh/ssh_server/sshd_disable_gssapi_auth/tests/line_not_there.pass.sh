#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i "/^GSSAPIAuthentication.*/d" /etc/ssh/sshd_config
