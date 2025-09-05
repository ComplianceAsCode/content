#!/bin/bash

# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/typeset -xr TMOUT=800/" /etc/profile
else
	echo "typeset -xr TMOUT=800" >> /etc/profile
fi
