#!/bin/bash
# remediation = none

# The sets up a config file with extra double quotes

{{%- if VARIABLE %}}
# variables = {{{ VARIABLE }}}=correct_value
{{%- set VALUE="correct_value" %}}
{{%- endif %}}

source common.sh

for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i 's/{{{ CONFIG }}}.*/{{{ CONFIG }}}="{{{ VALUE }}}""/' "$file"
    else
        echo '{{{ CONFIG }}}="{{{ VALUE }}}""' >> "$file"
    fi
done
