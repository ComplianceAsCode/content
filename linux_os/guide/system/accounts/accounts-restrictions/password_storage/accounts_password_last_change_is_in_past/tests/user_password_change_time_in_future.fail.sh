#!/bin/bash
# remediation = none

# create valid testuser
echo 'testuservalid:$6$rounds=65536$exIFis0tobKRcGBk$b.UR.Z8h96FdxJ1bgA/vhdnp0Lsm488swdILNguQX/5qH5hdmClyYb5xk3TpELXWzr4JOiTlHfRkPsXSjMPjv0:19396:1:60:7:35::' >> /etc/shadow

TEST_USER="testUserChage1"

useradd $TEST_USER
echo -e "testpass\ntestpass" | passwd $TEST_USER

TODAY="$(($(date +%s)/86400))"
TOMORROW="$(( TODAY + 1 ))"

awk -v newdate="$TOMORROW" -v test_user="$TEST_USER" 'BEGIN { FS=":"; OFS = ":"} \
    {  if($1 ==test_user) ($3=newdate); print}' /etc/shadow > /etc/shadow_new
mv /etc/shadow_new /etc/shadow
