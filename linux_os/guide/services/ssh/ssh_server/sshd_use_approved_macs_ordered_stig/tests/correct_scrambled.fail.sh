#!/bin/bash

{{% if product == "ubuntu2204" %}}
sshd_scrambled_macs="hmac-sha2-256,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
{{% else %}}
sshd_scrambled_macs="hmac-sha2-256,hmac-sha2-512"
{{% endif %}}

if grep -q "^MACs" /etc/ssh/sshd_config; then
	sed -i "s/^MACs.*/MACs $sshd_scrambled_macs/" /etc/ssh/sshd_config
else
	echo "MACs $sshd_scrambled_macs" >> /etc/ssh/sshd_config
fi
