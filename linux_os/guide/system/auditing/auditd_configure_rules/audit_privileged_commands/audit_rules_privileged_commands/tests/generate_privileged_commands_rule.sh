#!/bin/bash

AUID=$1
KEY=$2
RULEPATH=$3
for file in $(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null); do
     echo "-a always,exit -F path=$file -F auid>=$AUID -F auid!=unset -k $KEY" >> $RULEPATH
done
