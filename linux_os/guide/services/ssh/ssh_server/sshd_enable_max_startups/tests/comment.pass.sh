#!/bin/bash
#

if grep -q "^maxstartups" /etc/ssh/sshd_config; then
	sed -i "s/^maxstartups.*/# maxstartups 10:30:60/" /etc/ssh/sshd_config
else
	echo "# maxstartups 10:30:60" >> /etc/ssh/sshd_config
fi
