#!/bin/bash

# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

BAD_PAS_AGE=-1

# Configure the OS to enforce a password age < 1 of each accout  

system_users=( $(awk -F: '{print $1}' /etc/shadow) )
for i in ${system_users[@]}; 
do 
  passwd -n $BAD_PAS_AGE $i
done
