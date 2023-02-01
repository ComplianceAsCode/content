#!/bin/bash

TEST_USER="testUserChage1"

useradd $TEST_USER
echo -e "testpass\ntestpass" | passwd $TEST_USER

TODAY="$(($(date +%s)/86400))"
TOMORROW="$(( TODAY + 1 ))"

awk -v newdate="$TOMORROW" -v test_user="$TEST_USER" 'BEGIN { FS=":"; OFS = ":"} \
    {  if($1 ==test_user) ($3=newdate); print}' /etc/shadow > /etc/shadow_new
mv /etc/shadow_new /etc/shadow
