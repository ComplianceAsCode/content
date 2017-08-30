#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_nist-800-171-cui

sed -i "/^net.ipv4.conf.default.secure_redirects.*/d" /etc/sysctl.conf
