#!/bin/bash
# variables = var_accounts_user_umask = 027

sed -i '/umask/d' /etc/profile
sed -i '/umask/d' /etc/profile.d/*
echo "umask 000" >> /etc/profile.d/umask.sh
umask 000
