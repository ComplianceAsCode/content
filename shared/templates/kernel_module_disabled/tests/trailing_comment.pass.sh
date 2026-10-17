#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/false # disabled by policy" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
echo "blacklist {{{ KERNMODULE }}} # disabled by policy" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
