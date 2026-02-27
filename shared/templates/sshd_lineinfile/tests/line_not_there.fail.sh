#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{% if product == 'sle16' %}}
touch /etc/ssh/sshd_config
sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* /usr/etc/ssh/sshd_config /usr/etc/ssh/sshd_config.d/*
{{% else %}}
sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
{{% endif %}}
