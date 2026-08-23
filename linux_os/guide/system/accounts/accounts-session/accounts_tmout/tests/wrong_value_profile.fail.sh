#!/bin/bash

# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "^TMOUT" /etc/profile; then
	sed -i "s/^TMOUT.*/TMOUT=950/" /etc/profile
else
	echo "TMOUT=950" >> /etc/profile
fi
