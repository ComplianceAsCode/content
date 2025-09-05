#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile

if grep -q "TMOUT" /etc/profile.d/tmout.sh; then
	sed -i "s/.*TMOUT.*/declare -xr TMOUT=700/" /etc/profile.d/tmout.sh
	echo "declare -xr TMOUT=800" >> /etc/profile.d/tmout.sh
else
	echo "declare -xr TMOUT=700" >> /etc/profile.d/tmout.sh
	echo "declare -xr TMOUT=800" >> /etc/profile.d/tmout.sh
fi
