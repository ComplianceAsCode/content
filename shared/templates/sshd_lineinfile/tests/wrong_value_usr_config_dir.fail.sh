#!/bin/bash
# platform = SUSE Linux Enterprise 16

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

touch /usr/etc/ssh/sshd_config.d/oscap-sshd-config.conf

if grep -q "^\s*{{{ PARAMETER }}}" /usr/etc/ssh/sshd_config /usr/etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" /usr/etc/ssh/sshd_config /usr/etc/ssh/sshd_config.d/*
fi

echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" > /usr/etc/ssh/sshd_config.d/oscap-sshd-config.conf
