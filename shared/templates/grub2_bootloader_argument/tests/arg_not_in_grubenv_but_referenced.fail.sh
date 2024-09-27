#!/bin/bash

# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# packages = grub2,grubby

source common.sh

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

for entry in /boot/loader/entries/*.conf; do
  if ! grep -q '\$kernelopts' "$entry"; then
    sed -i 's/^\(options.*\)$/\1 \$kernelopts/' "$entry"
  fi
done
