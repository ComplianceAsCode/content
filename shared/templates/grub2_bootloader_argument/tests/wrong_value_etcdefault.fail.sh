#!/bin/bash

# platform = multi_platform_all

{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}
{{#- Wrong value: right argument name, wrong value (e.g. audit_backlog_limit=8191) #}}
{{%- set ARG_NAME_VALUE_WRONG= ARG_NAME ~ "=" ~ TEST_VALUE_FAIL %}}

source common.sh

# --- Setup: populate /etc/default/grub with correct value and update grub.cfg ---
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"{{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub
{{{ grub_command("update") }}}

# --- Make oscap fail: set wrong value in /etc/default/grub ---
echo "GRUB_CMDLINE_LINUX=\"{{{ ARG_NAME_VALUE_WRONG }}}\"" > /etc/default/grub
