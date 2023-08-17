#!/bin/bash

source common.sh

# pass 2 is the second pass scenario

{{%- if VALUE == "n" %}}
# When the value is "n", the rule should pass when commented out
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i "s/^{{{ CONFIG }}}.*/# {{{ CONFIG }}}=y/" /boot/config-*
    else
        echo "# {{{ CONFIG }}}=y" >> "$file"
    fi
done
{{% else %}}
{{%- if VARIABLE %}}
# variables = {{{ VARIABLE }}}=correct_value
{{%- set VALUE="correct_value" %}}
{{%- endif %}}
# The second passing scenario is when the is double quoted, like VALUE="correct_value"
# (The test suite doesn't support dinamic pass fail handling)
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i 's/^{{{ CONFIG }}}.*/{{{ CONFIG }}}="{{{ VALUE }}}"/' "$file"
    else
        echo '{{{ CONFIG }}}="{{{ VALUE }}}"' >> "$file"
    fi
done
{{%- endif %}}

