#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile /etc/profile.d/*.sh /etc/bashrc

echo "typeset -xr TMOUT=700" >> /etc/profile
echo "typeset -xr TMOUT=800" >> /etc/profile.d/tmout.sh
