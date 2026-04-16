#!/bin/bash

# platform = multi_platform_fedora,multi_platform_rhel
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_CORRECT_VALUE %}}
{{%- endif %}}

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Removes argument from kernel command line in /boot/loader/entries/*.conf

for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*\<{{{ ARG_NAME }}}\>=\?.*' "$file" ; then
	    sed -i 's/\(^.*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*\)/\1 \2/' "$file"
  fi
# ensure that grubenv is not referenced
  if grep -q '\$kernelopts' "$file"; then
    sed -i 's/^\(options.*\)\$kernelopts\(.*\)$/\1\2/' "$file"
  fi
done
