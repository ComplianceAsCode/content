#!/bin/bash
# platform multi_platform_rhel,multi_platform_ol

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
