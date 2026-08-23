#!/bin/bash

# remove offending users who don't have existing GIDs
while read -r line ; do
    login=$(echo $line | cut -f1 -d':')
    gid=$(echo $line | cut -f4 -d':')
    if ! cut -f3 -d':' /etc/group | grep -q "$gid" ; then
        userdel -f $login
    fi
done < "/etc/passwd"
