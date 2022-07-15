#!/bin/bash
# platform Oracle Linux 7, Oracle Linux 8, Red Hat Enterprise Linux 7, Red Hat Enterprise Linux 8

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
