#!/bin/bash

# pass 2 is the second pass scenario

{{%- if VALUE == "n" %}}
# When the value is "n", the rule should pass when commented out
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG | upper }}} "$file" ; then
        sed -i "s/^{{{ CONFIG | upper }}}.*/# {{{ CONFIG | upper }}}=y/" /boot/config-*
    else
        echo "# {{{ CONFIG | upper }}}=y" >> "$file"
    fi
done
{{% else %}}
# There is only one passing scenario when we set VALUE="y", so pass2 is identical to pass1
# (The test suite doesn't support dinamic pass fail handling)
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG | upper }}} "$file" ; then
        sed -i "s/^{{{ CONFIG | upper }}}.*/{{{ CONFIG | upper }}}={{{ VALUE }}}/" "$file"
    else
        echo "{{{ CONFIG | upper }}}={{{ VALUE }}}" >> "$file"
    fi
done
{{%- endif %}}

