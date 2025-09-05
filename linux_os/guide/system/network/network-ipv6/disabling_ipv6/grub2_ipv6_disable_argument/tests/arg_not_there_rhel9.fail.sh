#!/bin/bash
# platform = Red Hat Enterprise Linux 9

# Removes ipv6.disable argument from kernel command line in //boot/loader/entries/*.conf

for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*ipv6\.disable=.*'  "$file" ; then
    sed -i 's/\(^.*\)ipv6\.disable=[^[:space:]]*\(.*\)/\1 \2/'  "$file"
  fi
done
