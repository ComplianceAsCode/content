#!/bin/bash

if [[ ! -d /run/modules-load.d ]]; then
    mkdir -p /run/modules-load.d
fi

echo "install {{{ KERNMODULE }}} /bin/true" > /run/modules-load.d/{{{ KERNMODULE }}}.conf
