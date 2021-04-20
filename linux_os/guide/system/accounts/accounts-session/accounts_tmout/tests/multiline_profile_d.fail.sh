#!/bin/bash

# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile

if grep -q "TMOUT" /etc/profile.d/tmout.sh; then
	sed -i "s/.*TMOUT.*/TMOUT=950; readonly TMOUT; export TMOUT/" /etc/profile.d/tmout.sh
else
	echo "TMOUT=950; readonly TMOUT; export TMOUT" >> /etc/profile.d/tmout.sh
fi
