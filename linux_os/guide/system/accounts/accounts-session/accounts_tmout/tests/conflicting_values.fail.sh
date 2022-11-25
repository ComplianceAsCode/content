#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile.d/*.sh /etc/profile /etc/bashrc

echo "declare -xr TMOUT=700" >> /etc/profile.d/tmout.sh
echo "declare -xr TMOUT=1700" >> /etc/bashrc
