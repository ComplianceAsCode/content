#!/bin/bash
#
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_cis

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/# Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se/" /etc/ssh/sshd_config
else
	echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se" >> /etc/ssh/sshd_config
fi
