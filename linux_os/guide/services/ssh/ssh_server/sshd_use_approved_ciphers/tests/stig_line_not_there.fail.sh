#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_stig

sed -i "/^Ciphers.*/d" /etc/ssh/sshd_config
