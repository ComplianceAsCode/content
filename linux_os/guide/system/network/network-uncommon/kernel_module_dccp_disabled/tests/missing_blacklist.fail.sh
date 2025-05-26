#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol,multi_platform_almalinux

rm -f /etc/modprobe.d/dccp-blacklist.conf
echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
