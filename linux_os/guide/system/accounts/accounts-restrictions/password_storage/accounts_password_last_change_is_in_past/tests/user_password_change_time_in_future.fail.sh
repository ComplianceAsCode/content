#!/bin/bash
# remediation = none

# create testuser entry in /etc/shadow
TEST_USER="testuser"
echo "$TEST_USER:\$6\$exIFis0tobKRcGBk\$b.UR.Z8h96FdxJ1bgA/vhdnp0Lsm488swdILNguQX/5qH5hdmClyYb5xk3TpELXWzr4JOiTlHfRkPsXSjMPjv0:19396:1:60:7:35::" >> /etc/shadow

TODAY="$(($(date +%s)/86400))"
TOMORROW="$(( TODAY + 1 ))"

# Ensure the sp_lstchg field holds a value which represents a date in the future
awk -v newdate="$TOMORROW" -v test_user="$TEST_USER" 'BEGIN { FS=":"; OFS = ":"} \
    {  if($1 ==test_user) ($3=newdate); print}' /etc/shadow > /etc/shadow_new
mv /etc/shadow_new /etc/shadow
