#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol,multi_platform_almalinux,multi_platform_ubuntu

sed -i /{{{ KERNMODULE }}}/d /etc/modprobe.d/*.conf
echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
