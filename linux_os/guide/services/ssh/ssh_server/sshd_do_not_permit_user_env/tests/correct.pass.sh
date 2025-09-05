#!/bin/bash

if grep -q '.*PermitUserEnvironment.*' /etc/ssh/sshd_config; then
	sed -i 's/^.*PermitUserEnvironment.*$/PermitUserEnvironment no/' /etc/ssh/sshd_config
else
	echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
fi
