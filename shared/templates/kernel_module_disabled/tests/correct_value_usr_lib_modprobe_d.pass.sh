#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /usr/lib/modprobe.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /usr/lib/modprobe.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
