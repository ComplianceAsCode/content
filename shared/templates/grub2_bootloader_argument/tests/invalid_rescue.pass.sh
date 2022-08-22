#!/bin/bash

# platform = Red Hat Enterprise Linux 9,multi_platform_fedora
# packages = grub2,grubby
{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Rule should find this file and notice it is not right
# - This method hits only limited repos above
echo "I am an invalid boot entry, but nobody should care, because I am rescue" > /boot/loader/entries/trololol-rescue.conf
