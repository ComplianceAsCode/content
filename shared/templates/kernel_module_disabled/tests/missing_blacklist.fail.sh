#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol,multi_platform_ubuntu

echo > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
