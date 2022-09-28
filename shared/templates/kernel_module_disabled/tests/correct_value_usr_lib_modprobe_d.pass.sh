#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /usr/lib/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8"] or 'rhel' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /usr/lib/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
