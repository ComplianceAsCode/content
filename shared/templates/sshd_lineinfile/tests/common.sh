#!/bin/bash

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*{{{ PARAMETER }}}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
	sed -i "s/^{{{ PARAMETER }}}.*/# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}/g" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
else
	echo "# {{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config
fi
