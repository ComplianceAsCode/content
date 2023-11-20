#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/typeset -xr TMOUT=700/" /etc/profile
	echo "typeset -xr TMOUT=600" >> /etc/profile.d/tmout.sh
else
	echo "typeset -xr TMOUT=700" >> /etc/profile
	echo "typeset -xr TMOUT=600" >> /etc/profile.d/tmout.sh
fi
