#!/bin/bash

BAD_PAS_WARN_AGE=3

# Configure the OS to enforce a PASS_WARN_AGE < 7 of each accout
system_users=( $(awk -F: '{print $1}' /etc/shadow) )
for i in ${system_users[@]};
do
  chage --warndays $BAD_PAS_WARN_AGE $i
done
