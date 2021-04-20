#!/bin/bash

# variables = var_accounts_tmout=700

if grep -q "TMOUT" /etc/profile.d/tmout.sh; then
	sed -i "s/.*TMOUT.*/TMOUT=700; readonly TMOUT; export TMOUT/" /etc/profile.d/tmout.sh
else
	echo "TMOUT=700; readonly TMOUT; export TMOUT" >> /etc/profile.d/tmout.sh
fi
