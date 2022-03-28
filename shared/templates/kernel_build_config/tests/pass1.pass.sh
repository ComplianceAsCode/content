#!/bin/bash

# pass1 is the plain expected pass scenario

{{%- if VALUE == "n" %}}
# When the value is "n", the rule should pass when absent
sed -i "/^{{{ CONFIG | upper }}}.*/d" /boot/config-*
{{% else %}}
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG | upper }}} "$file" ; then
        sed -i "s/^{{{ CONFIG | upper }}}.*/{{{ CONFIG | upper }}}={{{ VALUE }}}/" "$file"
    else
        echo "{{{ CONFIG | upper }}}={{{ VALUE }}}" >> "$file"
    fi
done
{{%- endif %}}
