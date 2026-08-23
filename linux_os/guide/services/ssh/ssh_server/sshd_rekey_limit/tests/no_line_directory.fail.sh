#!/bin/bash
{{% if sshd_distributed_config == "false" %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -iq "^\s*RekeyLimit\b" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*RekeyLimit\b/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi
