#!/bin/bash
#
# platform = Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_stig

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/# Ciphers aes128-ctr,aes192-ctr,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc/" /etc/ssh/sshd_config
else
	echo "Ciphers aes128-ctr,aes192-ctr,aes128-cbc,aes192-cbc,aes256-cbc,3des-cbc" >> /etc/ssh/sshd_config
fi
