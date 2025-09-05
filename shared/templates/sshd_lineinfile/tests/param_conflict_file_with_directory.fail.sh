#!/bin/bash

# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 9,multi_platform_ubuntu

SSHD_PARAM={{{ PARAMETER }}}
SSHD_VAL={{{ VALUE }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s") }}}
{{% endif %}}

if grep -q "^\s*${SSHD_PARAM}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "${SSHD_PARAM} ${SSHD_VAL}" >> /etc/ssh/sshd_config
echo "${SSHD_PARAM} bad_val" > /etc/ssh/sshd_config.d/bad_config.conf
