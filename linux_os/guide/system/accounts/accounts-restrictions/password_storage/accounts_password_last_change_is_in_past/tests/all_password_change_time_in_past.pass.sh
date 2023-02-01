#!/bin/bash

TODAY="$(($(date +%s)/86400))"
DAY_AGO="$(( TODAY - 1 ))"

awk -v newdate="$DAY_AGO" 'BEGIN { FS=":"; OFS = ":"} 
    {$3=newdate; print}' /etc/shadow > /etc/shadow_new

mv /etc/shadow_new /etc/shadow
