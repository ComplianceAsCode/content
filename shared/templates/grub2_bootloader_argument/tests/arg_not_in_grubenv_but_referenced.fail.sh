#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby
{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_CORRECT_VALUE %}}
{{%- endif %}}

source common.sh

for entry in /boot/loader/entries/*.conf; do
  if ! grep -q '\$kernelopts' "$entry"; then
    sed -i 's/^\(options.*\)$/\1 \$kernelopts/' "$entry"
  fi
done
