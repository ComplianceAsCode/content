#!/bin/bash

# platform = Red Hat Enterprise Linux 9,multi_platform_fedora
# packages = grub2,grubby

source common.sh

# Removes argument from kernel command line in /boot/loader/entries/*.conf

for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*{{{ ESCAPED_ARG_NAME }}}=.*'  "$file" ; then
      # modify the GRUB command-line if an ={{{ARG_NAME}}} arg already exists
	    sed -i 's/\(^.*\){{{ARG_NAME}}}=[^[:space:]]*\(.*\)/\1 {{{ARG_NAME}}}=wrong \2/'  "$file"
    else
	    # no {{{ARG_NAME}}}=arg is present, append it
	    sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ARG_NAME}}}=wrong/'  "$file"
  fi
done
