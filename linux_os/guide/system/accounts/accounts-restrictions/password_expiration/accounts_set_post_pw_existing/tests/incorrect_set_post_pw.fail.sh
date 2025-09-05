#!/bin/bash

# packages = passwd

BAD_INACTIVE=60

# Configure the OS to disable INACTIVE setting of each accout  
system_users=( $(awk -F: '{print $1}' /etc/shadow) )
for i in ${system_users[@]};
do
  chage --inactive $BAD_INACTIVE $i
done
