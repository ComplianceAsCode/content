#!/bin/bash

{{% if OPERATION == "pattern match" %}}
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
# variables = {{{ ARG_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{% endif %}}

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME ~ "=" ~ TEST_WRONG_VALUE) }}}
