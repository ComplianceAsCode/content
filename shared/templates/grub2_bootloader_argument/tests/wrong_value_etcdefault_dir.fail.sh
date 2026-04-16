#!/bin/bash

# platform = multi_platform_ubuntu
# packages = grub2

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_CORRECT_VALUE %}}
{{%- endif %}}

# Clean up and make sure we are at a passing state
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"\"" > /etc/default/grub
echo "GRUB_CMDLINE_LINUX=\"{{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub.d/custom.cfg
{{{ grub_command("update") }}}

# Set to wrong var/value
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX {{{ ARG_NAME }}}={{{ TEST_WRONG_VALUE }}}\"" > /etc/default/grub.d/custom.cfg

