#!/bin/bash

if [ ! -e /boot/config-$(uname -r) ]; then
    mkdir -p /boot
    touch /boot/config-$(uname -r)
fi
