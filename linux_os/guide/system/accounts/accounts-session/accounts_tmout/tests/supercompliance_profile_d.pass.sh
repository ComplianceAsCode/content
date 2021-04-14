#!/bin/bash

# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile

if grep -q "TMOUT" /etc/profile.d/tmout.sh; then
	sed -i "s/.*TMOUT.*/TMOUT=800/" /etc/profile.d/tmout.sh
else
	echo "TMOUT=800" >> /etc/profile.d/tmout.sh
fi
