#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 9
# variables = var_sshd_set_keepalive=1

SSHD_CONFIG="/etc/ssh/sshd_config.d/00-complianceascode-hardening.conf"

. "$SHARED/utilities.sh"

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*ClientAliveCountMax" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "/^\s*ClientAliveCountMax.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

assert_directive_in_file "$SSHD_CONFIG" ClientAliveCountMax "ClientAliveCountMax 1"
