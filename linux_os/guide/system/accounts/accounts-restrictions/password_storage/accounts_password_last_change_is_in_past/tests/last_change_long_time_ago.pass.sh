#!/bin/bash

# create valid testuser entry in /etc/shadow
echo 'testuservalid:$6$exIFis0tobKRcGBk$b.UR.Z8h96FdxJ1bgA/vhdnp0Lsm488swdILNguQX/5qH5hdmClyYb5xk3TpELXWzr4JOiTlHfRkPsXSjMPjv0:10000:1:60:7:35::' >> /etc/shadow

TODAY="$(($(date +%s)/86400))"
MANY_YEARS_AGO="$(( TODAY - 10000 ))"

# Ensure the sp_lstchg field holds a value which represents a date in the past
awk -v newdate="$MANY_YEARS_AGO" 'BEGIN { FS=":"; OFS = ":"}
    {$3=newdate; print}' /etc/shadow > /etc/shadow_new

mv /etc/shadow_new /etc/shadow
