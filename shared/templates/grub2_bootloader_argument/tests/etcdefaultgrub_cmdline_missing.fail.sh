#!/bin/bash

# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 10
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{%- endif %}}

source common.sh

# --- Make oscap fail: no GRUB_CMDLINE_LINUX in /etc/default/grub ---
# grubby does not add GRUB_CMDLINE_LINUX when it is missing, so the remediation has to
sed -i '/^\s*GRUB_CMDLINE_LINUX=/d' '/etc/default/grub'
