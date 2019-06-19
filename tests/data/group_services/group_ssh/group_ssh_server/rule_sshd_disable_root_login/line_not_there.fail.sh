#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i "/^PermitRootLogin.*/d" /etc/ssh/sshd_config
