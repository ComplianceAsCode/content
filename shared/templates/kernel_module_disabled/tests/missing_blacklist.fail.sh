#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol,multi_platform_almalinux,multi_platform_ubuntu,multi_platform_debian

sed -i /{{{ KERNMODULE }}}/d /etc/modprobe.d/*.conf
echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
