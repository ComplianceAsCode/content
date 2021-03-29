#!/bin/bash

# variables = var_accounts_tmout=900

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=950; readonly TMOUT; export TMOUT/" /etc/profile
else
	echo "TMOUT=950; readonly TMOUT; export TMOUT" >> /etc/profile
fi
