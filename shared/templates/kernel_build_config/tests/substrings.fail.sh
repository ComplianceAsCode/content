#!/bin/bash
# remediation = none

# Test matches against larger strings

{{%- if VARIABLE %}}
# variables = {{{ VARIABLE }}}=correct_value
{{%- set SUPER_VALUE="XYZcorrect_value" %}}
{{%- else %}}
{{%- set SUPER_VALUE='XYZ' ~ VALUE %}}
{{%- endif %}}

source common.sh

for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i "s/{{{ CONFIG }}}.*/{{{ CONFIG }}}={{{ SUPER_VALUE }}}/" "$file"
    else
        echo "{{{ CONFIG }}}={{{ SUPER_VALUE }}}" >> "$file"
    fi
done
