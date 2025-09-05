#!/bin/bash

if [[ ! -d /run/modprobe.d ]]; then
    mkdir -p /run/modprobe.d
fi
echo "install {{{ KERNMODULE }}} /bin/true" > /run/modprobe.d/{{{ KERNMODULE }}}.conf
