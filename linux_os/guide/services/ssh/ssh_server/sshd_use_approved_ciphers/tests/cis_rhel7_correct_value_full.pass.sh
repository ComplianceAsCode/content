#!/bin/bash
#
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_cis

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-cbc,aes192-cbc,aes256-cbc,blowfish-cbc,cast128-cbc,3des-cbc/" /etc/ssh/sshd_config
else
	echo 'Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-cbc,aes192-cbc,aes256-cbc,blowfish-cbc,cast128-cbc,3des-cbc' >> /etc/ssh/sshd_config
fi
