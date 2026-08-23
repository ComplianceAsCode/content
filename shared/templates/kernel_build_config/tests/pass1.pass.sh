#!/bin/bash

{{%- if VARIABLE %}}
# variables = {{{ VARIABLE }}}=correct_value
{{%- endif %}}

source common.sh

# pass1 is the plain expected pass scenario

{{%- if VALUE == "n" %}}
# When the value is "n", the rule should pass when absent
sed -i "/^{{{ CONFIG }}}.*/d" /boot/config-*
{{% else %}}
{{%- if VARIABLE %}}
{{%- set VALUE="correct_value" %}}
{{%- endif %}}
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i "s/^{{{ CONFIG }}}.*/{{{ CONFIG }}}={{{ VALUE }}}/" "$file"
    else
        echo "{{{ CONFIG }}}={{{ VALUE }}}" >> "$file"
    fi
done
{{%- endif %}}
