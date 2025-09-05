#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

sed -i "/^\s*${SSHD_PARAM}.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
