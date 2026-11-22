#!/bin/bash
#
# profiles = ospp

if grep -q "^TMOUT" /etc/profile; then
	sed -i "s/^TMOUT.*/TMOUT=1234/" /etc/profile
else
	echo "TMOUT=1234" >> /etc/profile
fi
