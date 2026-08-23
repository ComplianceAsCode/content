#!/bin/bash

# platform = multi_platform_ubuntu
# packages = grub2

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}

# --- Setup: clear grub.d and update grub.cfg to empty state ---
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"\"" > /etc/default/grub
{{{ grub_command("update") }}}

# --- Make oscap fail: set correct value in grub.d without updating grub.cfg ---
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX {{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub.d/custom.cfg

