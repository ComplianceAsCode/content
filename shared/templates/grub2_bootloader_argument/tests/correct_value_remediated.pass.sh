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
{{%- endif %}}

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}
