#!/bin/bash

# platform = multi_platform_sle,multi_platform_ubuntu
# variables = var_accounts_tmout=900

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=950\nreadonly TMOUT\nexport TMOUT/" /etc/profile
else
	echo -e "TMOUT=950\nreadonly TMOUT\nexport TMOUT" >> /etc/profile
fi
