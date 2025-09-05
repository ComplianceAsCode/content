#!/bin/bash

# platform = multi_platform_sle

SECURE_INACTIVE=30

users_to_set=( $(awk -v var=\"$SECURE_INACTIVE\" -F: '$7 > var || $7 == "" {print $1}' /etc/shadow) )
for i in ${users_to_set[@]};
do
   chage --inactive $SECURE_INACTIVE $i
done
