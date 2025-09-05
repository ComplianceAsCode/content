#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile /etc/profile.d/*.sh /etc/bashrc

echo "declare -xr TMOUT=700" >> /etc/profile
echo "declare -xr TMOUT=800" >> /etc/profile.d/tmout.sh
