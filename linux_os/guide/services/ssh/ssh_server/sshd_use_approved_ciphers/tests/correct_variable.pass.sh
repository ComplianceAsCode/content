#!/bin/bash

# variables = sshd_approved_ciphers=ijkl158,sits,wwq-98,kl24

if grep -q "^Ciphers" /etc/ssh/sshd_config; then
	sed -i "s/^Ciphers.*/Ciphers ijkl158,sits,wwq-98,kl24/" /etc/ssh/sshd_config
else
	echo 'Ciphers ijkl158,sits,wwq-98,kl24' >> /etc/ssh/sshd_config
fi
