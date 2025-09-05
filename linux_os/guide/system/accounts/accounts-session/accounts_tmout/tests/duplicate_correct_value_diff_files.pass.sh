#!/bin/bash

# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile /etc/profile.d/*.sh

echo "declare -xr TMOUT=700" >> /etc/profile
echo "declare -xr TMOUT=700" >> /etc/profile.d/tmout.sh
