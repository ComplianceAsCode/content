#!/bin/bash
{{% if IS_SUBSTRING != "true" %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}
{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

{{%- set ARG_NAME_VALUE= ARG_NAME_VALUE ~ "A" %}}

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}
