#!/bin/bash

{{% if OPERATION == "greater than or equal" %}}
# platform = multi_platform_all
{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}
{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}={{{ VALUE_AT_THRESHOLD }}}
{{%- endif %}}

source common.sh

# --- Setup: populate all GRUB configs with value above GTE threshold ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME ~ "=" ~ VALUE_ABOVE) }}}
{{% else %}}
# platform = Not Applicable
source common.sh
{{% endif %}}
