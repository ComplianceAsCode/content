#!/bin/bash

if [ -f /etc/modprobe.d/{{{ KERNMODULE }}}.conf ]; then
    sed -i '/install cramfs/d' /etc/modprobe.d/{{{ KERNMODULE }}}.conf
fi
echo "# install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
