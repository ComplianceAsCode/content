#!/bin/bash

useradd testUserChage1
echo -e "testpass\ntestpass" | passwd testUserChage1

TODAY="$(($(date +%s)/86400))"
TOMORROW="$(( TODAY + 1 ))"

awk -v newdate="$TOMORROW" 'BEGIN { FS=":"; OFS = ":"} {  if($1 =="testUserChage1") ($3=newdate); print}' /etc/shadow > /etc/shadow_new

mv /etc/shadow_new /etc/shadow
