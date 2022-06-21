#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/declare -xr TMOUT=700/" /etc/profile
else
	echo "declare -xr TMOUT=700" >> /etc/profile
fi
