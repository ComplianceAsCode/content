#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

source common.sh

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "   InCLude", "sshd_config.d/*.conf", "%s %s") }}}
echo "   INclUde /etc/dummy" >> "/etc/ssh/sshd_config"

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{%- endif %}}

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/dummy
echo "{{{ PARAMETER }}} {{{ correct_VALUE }}}" >> /etc/ssh/sshd_config.d/other.conf
