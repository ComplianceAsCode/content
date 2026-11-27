#!/bin/bash

echo "install {{{ KERNMODULE }}} /usr/bin/false" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
