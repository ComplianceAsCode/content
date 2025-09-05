#!/bin/bash

# platform = multi_platform_sle
# variables = var_accounts_tmout=700

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=700; readonly TMOUT; export TMOUT/" /etc/profile
else
	echo "TMOUT=700; readonly TMOUT; export TMOUT" >> /etc/profile
fi
