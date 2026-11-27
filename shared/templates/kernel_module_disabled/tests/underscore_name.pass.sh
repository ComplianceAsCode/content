#!/bin/bash

echo "install {{{ KERNMODULE | replace("-", "_") }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
echo "blacklist {{{ KERNMODULE | replace("-", "_") }}}" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
