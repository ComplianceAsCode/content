#!/bin/bash

# platform = multi_platform_sle

MAX_PAS_AGE=99999

# Configure the OS to enforce a maximum password age of each accout  

system_users=( $(awk -F: '{print $1}' /etc/shadow) )
for i in ${system_users[@]}; 
do 
  passwd -x $MAX_PAS_AGE $i
done
