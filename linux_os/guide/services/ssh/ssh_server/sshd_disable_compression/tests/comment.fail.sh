#!/bin/bash

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

if grep -q "^\s*Compression" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* ; then
        sed -i "s/^Compression.*/# Compression no/g" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
    else
        echo "# Compression no" >> /etc/ssh/sshd_config
fi
