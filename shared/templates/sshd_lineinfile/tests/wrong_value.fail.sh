#!/bin/bash

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*{{{ PARAMETER }}}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" >> /etc/ssh/sshd_config
