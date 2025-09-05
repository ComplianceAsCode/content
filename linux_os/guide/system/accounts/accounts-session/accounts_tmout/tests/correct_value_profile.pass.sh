#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/typeset -xr TMOUT=700/" /etc/profile
else
	echo "typeset -xr TMOUT=700" >> /etc/profile
fi
