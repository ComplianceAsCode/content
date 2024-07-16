#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -iq "^\s*Include" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*Include.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

# Simple relative include
echo "Include sshd_config.d/bad_config1.conf" >> /etc/ssh/sshd_config
# Case insensitive relative include
echo "iNcLudE sshd_config.d/bad_config2.conf" >> /etc/ssh/sshd_config
# Leading spaces relative include
echo "   Include sshd_config.d/bad_config3.conf" >> /etc/ssh/sshd_config
# Simple include
echo "Include /etc/ssh/sshd_config.d/bad_config4.conf" >> /etc/ssh/sshd_config
# Case insensitive include
echo "iNcLudE /etc/ssh/sshd_config.d/bad_config5.conf" >> /etc/ssh/sshd_config
# Leading spaces include
echo "   Include /etc/ssh/sshd_config.d/bad_config6.conf" >> /etc/ssh/sshd_config

if grep -q "^\s*{{{ PARAMETER }}}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*{{{ PARAMETER }}}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

for i in {1..6}; do
	echo "{{{ PARAMETER }}} {{{ WRONG_VALUE }}}" > "/etc/ssh/sshd_config.d/bad_config${i}.conf"
done
