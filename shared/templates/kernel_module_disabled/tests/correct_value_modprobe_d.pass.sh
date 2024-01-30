#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/false" > /etc/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
