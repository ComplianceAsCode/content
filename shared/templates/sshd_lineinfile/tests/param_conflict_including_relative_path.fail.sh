#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "sshd_config.d/*.conf", "%s %s") }}}

if grep -q "^\s*{{{ PARAMETER }}}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" > /etc/ssh/sshd_config.d/good_config.conf
echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" > /etc/ssh/sshd_config.d/bad_config.conf
