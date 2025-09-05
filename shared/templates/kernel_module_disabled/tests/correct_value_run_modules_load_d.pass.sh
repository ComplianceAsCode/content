#!/bin/bash

if [[ ! -d /run/modules-load.d ]]; then
    mkdir -p /run/modules-load.d
fi

echo "install {{{ KERNMODULE }}} /bin/true" > /run/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if product in ["ol7", "ol8"] or 'rhel' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /run/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
