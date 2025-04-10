#!/bin/bash

{{% if product == "ubuntu2204" %}}
sshd_scrambled_ciphers="aes128-gcm@openssh.com,aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr"
{{% else %}}
sshd_scrambled_ciphers="aes128-ctr,aes192-ctr,aes256-ctr"
{{% endif %}}

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers $sshd_scrambled_ciphers/" /etc/ssh/sshd_config
else
	echo "Ciphers $sshd_scrambled_ciphers" >> /etc/ssh/sshd_config
fi
