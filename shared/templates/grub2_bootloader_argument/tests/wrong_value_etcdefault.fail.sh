#!/bin/bash

# platform = multi_platform_all

{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- set ARG_NAME_VALUE_WRONG= ARG_NAME ~ "=wrong_value" %}}
{{%- else %}}
{{%- set ARG_NAME_VALUE_WRONG= "wrong_variable" %}}
{{%- endif %}}

source common.sh

# Clean up and make sure we are at a passing state
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"{{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub
{{{ grub_command("update") }}}

# Set to wrong var/value
echo "GRUB_CMDLINE_LINUX=\"{{{ ARG_NAME_VALUE_WRONG }}}=\"" > /etc/default/grub
