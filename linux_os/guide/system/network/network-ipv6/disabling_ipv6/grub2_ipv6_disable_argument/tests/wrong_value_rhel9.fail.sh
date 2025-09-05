#!/bin/bash
# platform = Red Hat Enterprise Linux 9

# Break the ipv6.disable argument in kernel command line in /boot/loader/entries/*.conf

for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*ipv6\.disable=.*'  "$file" ; then
    # modify the GRUB command-line if an ipv6.disable= arg already exists
    sed -i 's/\(^.*\)ipv6\.disable=[^[:space:]]*\(.*\)/\1 ipv6\.disable=0 \2/'  "$file"
  else
    # no ipv6.disable=arg is present, append it
    sed -i 's/\(^.*\(vmlinuz\|kernelopts|options\).*\)/\1 ipv6\.disable=0/'  "$file"
  fi
done
