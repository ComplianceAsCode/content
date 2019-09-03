#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

sed -i "/^Ciphers.*/d" /etc/ssh/sshd_config
