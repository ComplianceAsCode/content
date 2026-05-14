#!/bin/bash

# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10,multi_platform_fedora
# packages = grub2,grubby

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_VALUE_PASS }}}
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=" ~ TEST_VALUE_PASS %}}
{{%- endif %}}

source common.sh

# --- Setup: populate all GRUB configs with correct value ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Rule should find this file and notice it is not right
# - This method hits only limited repos above
echo "I am an invalid boot entry, but nobody should care, because I am rescue" > /boot/loader/entries/trololol-rescue.conf
