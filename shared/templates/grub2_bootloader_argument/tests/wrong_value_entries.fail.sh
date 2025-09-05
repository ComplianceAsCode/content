#!/bin/bash

# platform = multi_platform_fedora,multi_platform_rhel
# packages = grub2,grubby

source common.sh

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- set ARG_NAME_VALUE_WRONG= ARG_NAME ~ "=wrong_value" %}}
{{%- else %}}
{{%- set ARG_NAME_VALUE_WRONG= "wrong_variable" %}}
{{%- endif %}}

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Breaks argument from kernel command line in /boot/loader/entries/*.conf
for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*{{{ ESCAPED_ARG_NAME }}}=.*'  "$file" ; then
      # modify the GRUB command-line if an ={{{ARG_NAME}}} arg already exists
	    sed -i 's/\(^.*\){{{ ARG_NAME }}}=[^[:space:]]*\(.*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}} \2/'  "$file"
    else
	    # no {{{ARG_NAME}}}=arg is present, append it
	    sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}}/'  "$file"
  fi
# ensure that grubenv is not referenced
  if  grep -q '\$kernelopts' "$file"; then
    sed -i 's/^\(options.*\)\$kernelopts\(.*\)$/\1\2/' "$file"
  fi
done
