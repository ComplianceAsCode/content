#!/bin/bash

# platform = multi_platform_fedora,multi_platform_rhel
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}
{{#- Wrong value: right argument name, wrong value (e.g. audit_backlog_limit=8191) #}}
{{%- set ARG_NAME_VALUE_WRONG= ARG_NAME ~ "=" ~ TEST_VALUE_FAIL %}}

source common.sh

# --- Setup: populate all GRUB configs with correct value ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# --- Make oscap fail: set wrong value in BLS entries ---
for file in /boot/loader/entries/*.conf ; do
  if grep -q '^.*\<{{{ ARG_NAME }}}\>=\?.*'  "$file" ; then
      # modify the GRUB command-line if an ={{{ARG_NAME}}} arg already exists
	    sed -i 's/\(^.*\)\<{{{ ARG_NAME }}}\>=\?[^[:space:]]*\(.*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}} \2/' "$file"
    else
	    # no {{{ARG_NAME}}}=arg is present, append it
	    sed -i 's/\(^.*\(vmlinuz\|kernelopts\).*\)/\1 {{{ ARG_NAME_VALUE_WRONG }}}/'  "$file"
  fi
# ensure that grubenv is not referenced
  if  grep -q '\$kernelopts' "$file"; then
    sed -i 's/^\(options.*\)\$kernelopts\(.*\)$/\1\2/' "$file"
  fi
done
