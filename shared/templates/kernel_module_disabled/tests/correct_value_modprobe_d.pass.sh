#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8", "rhel7", "rhel8"] %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
