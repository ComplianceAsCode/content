#!/bin/bash

# platform = multi_platform_sle,multi_platform_ubuntu
# variables = var_accounts_tmout=700

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=700\nreadonly TMOUT\nexport TMOUT/" /etc/profile
else
	echo -e "TMOUT=700\nreadonly TMOUT\nexport TMOUT" >> /etc/profile
fi
