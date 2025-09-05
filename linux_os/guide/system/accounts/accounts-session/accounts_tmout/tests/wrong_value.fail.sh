#!/bin/bash

# variables = var_accounts_tmout=200

if grep -q "^TMOUT" /etc/profile; then
	sed -i "s/^TMOUT.*/TMOUT=250/" /etc/profile
else
	echo "TMOUT=250" >> /etc/profile
fi
