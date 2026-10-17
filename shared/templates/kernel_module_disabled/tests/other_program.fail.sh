#!/bin/bash

echo "install {{{ KERNMODULE }}} /usr/bin/falsehood" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
