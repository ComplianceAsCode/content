#!/bin/bash
# Test: expected value appears inside a longer actual value (appended flags).
# Example: slub_debug on OL8 — profile expects "P", system has "PA" (P + extra flag).
# operation: pattern match finds "P" inside "PA" -> PASS.
#
# Only applicable when the rule uses operation: pattern match.

{{% if OPERATION == "pattern match" %}}
# platform = multi_platform_all
{{% else %}}
# platform = Not Applicable
{{% endif %}}
{{%- if 'ubuntu' in product %}}
# packages = grub2
{{%- else %}}
# packages = grub2,grubby
{{%- endif %}}

{{%- if ARG_VARIABLE %}}
# variables = {{{ ARG_VARIABLE }}}=correct_value
{{#- Rules that use arg_variable have no =value in ARG_NAME_VALUE, override with dummy #}}
{{%- set ARG_NAME_VALUE= ARG_NAME ~ "=correct_value" %}}
{{%- endif %}}

# Append "A" to the value: e.g. slub_debug=PA instead of slub_debug=P
{{%- set ARG_NAME_VALUE= ARG_NAME_VALUE ~ "A" %}}

source common.sh

# --- Setup: populate all GRUB configs with value containing extra leading chars ---
{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}
