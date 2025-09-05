#!/bin/bash

if grep -q 'maxclassrepeat' /etc/security/pwquality.conf; then
	sed -i 's/.*maxclassrepeat.*/maxclassrepeat = 4/' /etc/security/pwquality.conf
else
	echo "maxclassrepeat = 4" >> /etc/security/pwquality.conf
fi

