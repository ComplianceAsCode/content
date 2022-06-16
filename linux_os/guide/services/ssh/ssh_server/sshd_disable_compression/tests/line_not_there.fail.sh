#!/bin/bash

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

sed -i "/^\s*Compression.*/Id" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
