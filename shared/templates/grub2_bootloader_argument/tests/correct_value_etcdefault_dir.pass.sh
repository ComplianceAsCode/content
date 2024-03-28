#!/bin/bash

# platform = multi_platform_ubuntu
# packages = grub2

# Clean up
rm -f /etc/default/grub.d/*
echo "GRUB_CMDLINE_LINUX=\"\"" > /etc/default/grub

# Set the correct argument and update grub
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX {{{ ARG_NAME_VALUE }}}\"" > /etc/default/grub.d/custom.cfg
echo "GRUB_CMDLINE_LINUX=\"\$GRUB_CMDLINE_LINUX some_random_arg\"" > /etc/default/grub.d/custom2.cfg
{{{ grub_command("update") }}}

