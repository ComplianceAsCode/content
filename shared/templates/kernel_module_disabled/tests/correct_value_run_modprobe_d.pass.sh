#!/bin/bash

if [[ ! -d /run/modprobe.d ]]; then
    mkdir -p /run/modprobe.d
fi
echo "install {{{ KERNMODULE }}} /bin/true" > /run/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8", "rhel7", "rhel8"] %}}
echo "blacklist {{{ KERNMODULE }}}" >> /run/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
