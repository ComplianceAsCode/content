#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
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

# Break the argument in kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if grep -q '^.*{{{ARG_NAME}}}=.*'  "$file" ; then
	# modify the GRUB command-line if the arg already exists
	sed -i 's/\(^.*\){{{ ARG_NAME }}}=[^[:space:]]*\(.*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}}=wrong \2/'  "$file"
else
	# no arg is present, append it
	sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}}=wrong/'  "$file"
fi

# Ensure that grubenv is referenced through $kernelopts
# othervise contents of grubenv are ignored
for entry in /boot/loader/entries/*.conf; do
  if ! grep -q '\$kernelopts' "$entry"; then
    sed -i 's/^\(options.*\)$/\1 \$kernelopts/' "$entry"
  fi
done
