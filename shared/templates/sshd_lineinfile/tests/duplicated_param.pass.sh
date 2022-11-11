#!/bin/bash

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*{{{ PARAMETER }}}" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
fi

echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/ssh/sshd_config
echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/ssh/sshd_config
