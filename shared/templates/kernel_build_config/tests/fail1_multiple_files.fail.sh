#!/bin/bash
# remediation = none
{{%- if VARIABLE %}}
# variables = {{{ VARIABLE }}}=correct_value
{{%- set VALUE="correct_value" %}}
{{%- endif %}}

source common.sh

# fail1 is the plain expected fail scenario, the config with a wrong value
for file in /boot/config-* ; do
    if grep -q ^{{{ CONFIG }}} "$file" ; then
        sed -i "s/{{{ CONFIG }}}.*/{{{ CONFIG }}}=wrong_value/" "$file"
    else
        echo "{{{ CONFIG }}}=wrong_value" >> "$file"
    fi
done

# Ensure one config file is compliant
touch /boot/config-test
sed -i "s/{{{ CONFIG }}}.*/{{{ CONFIG }}}={{{ VALUE }}}/" /boot/config-test
