#!/bin/bash

# platform = multi_platform_ubuntu
# packages = grub2

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

# Clean up
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"\"" > /etc/default/grub
{{{ grub_command("update") }}}

# Set the correct argument without updating the grub.cfg
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX {{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub.d/custom.cfg

