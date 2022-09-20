#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8"] or 'rhel' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
