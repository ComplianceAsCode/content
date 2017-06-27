#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_nist-800-171-cui

sed -i "/^net.ipv4.conf.all.secure_redirects.*/d" /etc/sysctl.conf
# setting correct runtime value to check it properly
sysctl -w net.ipv4.conf.all.secure_redirects=0
