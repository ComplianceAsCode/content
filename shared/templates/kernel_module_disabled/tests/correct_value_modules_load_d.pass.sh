#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8", "rhel7", "rhel8"] %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
