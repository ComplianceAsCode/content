#!/bin/bash

# platform = Red Hat Enterprise Linux 7
# variables = var_accounts_tmout=700

sed -i "/.*TMOUT.*/d" /etc/profile /etc/profile.d/*.sh /etc/bashrc

echo "declare -xr TMOUT=800" >> /etc/bashrc
