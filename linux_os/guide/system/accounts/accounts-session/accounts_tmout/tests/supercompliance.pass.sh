#!/bin/bash

# variables = var_accounts_tmout=900

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=800/" /etc/profile
else
	echo "TMOUT=800" >> /etc/profile
fi
