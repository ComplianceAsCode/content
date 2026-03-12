#!/bin/bash
# platform = SUSE Linux Enterprise 16
source common.sh

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{%- endif %}}

if [ -e "/etc/ssh/sshd_config" ] ; then
    rm /etc/ssh/sshd_config
fi

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /usr/etc/ssh/sshd_config
