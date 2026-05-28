#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}

source common.sh

# --- Setup: populate all GRUB configs with correct value ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}
# ensure that the grubenv entry is not referenced
# also in RHEL 8, after performing previous steps, the only option is $kernelopts
# so add the arg=value there so that the test passes
for entry in /boot/loader/entries/*.conf; do
  if grep -q '\$kernelopts' "$entry"; then
    sed -i 's/^\(options.*\)\$kernelopts\(.*\)$/\1\2 mock {{{ ARG_NAME_VALUE }}}/' "$entry"
  fi
done
