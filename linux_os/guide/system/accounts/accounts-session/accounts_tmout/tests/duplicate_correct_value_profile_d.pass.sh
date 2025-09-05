#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile

if grep -q "TMOUT" /etc/profile.d/tmout.sh; then
	sed -i "s/.*TMOUT.*/TMOUT=700/" /etc/profile.d/tmout.sh
	echo "TMOUT=800" >> /etc/profile.d/tmout.sh
else
	echo "TMOUT=700" >> /etc/profile.d/tmout.sh
	echo "TMOUT=800" >> /etc/profile.d/tmout.sh
fi
