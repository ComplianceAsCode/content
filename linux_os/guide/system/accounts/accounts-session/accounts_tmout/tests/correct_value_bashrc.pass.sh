#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh /etc/profilea

if grep -q "TMOUT" /etc/bashrc; then
	sed -i "s/.*TMOUT.*/declare -xr TMOUT=700/" /etc/bashrc
else
	echo "declare -xr TMOUT=700" >> /etc/bashrc
fi
