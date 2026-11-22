#!/bin/bash
#
# profiles = ospp

if grep -q "^TMOUT" /etc/profile; then
	sed -i "s/^TMOUT.*/# TMOUT=600/" /etc/profile
else
	echo "# TMOUT=600" >> /etc/profile
fi
