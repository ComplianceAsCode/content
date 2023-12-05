#!/bin/bash

if [[ ! -d /run/modprobe.d ]]; then
    mkdir -p /run/modprobe.d
fi
echo "install {{{ KERNMODULE }}} /bin/true" > /run/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /run/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
