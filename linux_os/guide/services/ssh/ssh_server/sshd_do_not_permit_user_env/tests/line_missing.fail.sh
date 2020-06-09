#!/bin/bash

if grep -q '.*PermitUserEnvironment.*' /etc/ssh/sshd_config; then
	sed -i '/^.*PermitUserEnvironment.*$/d' /etc/ssh/sshd_config
fi
