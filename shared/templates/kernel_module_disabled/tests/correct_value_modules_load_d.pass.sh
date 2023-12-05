#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
