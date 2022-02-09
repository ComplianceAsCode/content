#!/bin/bash

if grep -q 'maxclassrepeat' /etc/security/pwquality.conf; then
	sed -i 's/.*maxclassrepeat.*/maxclassrepeat = -1/' /etc/security/pwquality.conf
else
	echo "maxclassrepeat = -1" >> /etc/security/pwquality.conf
fi
