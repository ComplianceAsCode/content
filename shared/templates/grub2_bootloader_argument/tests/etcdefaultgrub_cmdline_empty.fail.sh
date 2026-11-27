#!/bin/bash

# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 10
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{%- endif %}}

source common.sh

# --- Make oscap fail: empty GRUB_CMDLINE_LINUX in /etc/default/grub ---
# grubby does not update GRUB_CMDLINE_LINUX when it is empty, so the remediation has to
sed -i 's/^\s*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=""/' '/etc/default/grub'
