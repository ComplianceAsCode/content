#!/bin/bash
# remediation = none

source common.sh

# fail2 is the second fail scenario

{{%- if VALUE == "n" %}}
# There is only one fail scenario when VALUE="n", when the value is set to something
# This is similar to fail1, but excplicitly sets "y"
# (The test suite doesn't support dinamic pass fail handling)
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i "s/^{{{ CONFIG }}}.*/{{{ CONFIG }}}=y/" /boot/config-*
    else
        echo "{{{ CONFIG }}}=y" >> "$file"
    fi
done
{{% else %}}
# When we set VALUE="y", a missing config is a fail scenario
sed -i "/{{{ CONFIG }}}.*/d" /boot/config-*
{{%- endif %}}
