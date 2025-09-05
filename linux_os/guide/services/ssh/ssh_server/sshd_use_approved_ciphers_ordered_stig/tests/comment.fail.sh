#!/bin/bash

{{% if product == "ubuntu2204" %}}
sshd_approved_ciphers="aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr,aes128-gcm@openssh.com"
{{% else %}}
sshd_approved_ciphers="aes256-ctr,aes192-ctr,aes128-ctr"
{{% endif %}}

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/# ciphers $sshd_approved_ciphers/" /etc/ssh/sshd_config
else
	echo "# ciphers $sshd_approved_ciphers" >> /etc/ssh/sshd_config
fi
