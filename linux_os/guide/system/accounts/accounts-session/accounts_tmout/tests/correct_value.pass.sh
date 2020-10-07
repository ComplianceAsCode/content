#!/bin/bash

# variables = var_accounts_tmout=700

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=700/" /etc/profile
else
	echo "TMOUT=700" >> /etc/profile
fi
