#!/bin/bash

# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/declare -xr TMOUT=800/" /etc/profile
else
	echo "declare -xr TMOUT=800" >> /etc/profile
fi
