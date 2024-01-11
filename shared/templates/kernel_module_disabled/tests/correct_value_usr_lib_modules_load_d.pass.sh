#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /usr/lib/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "blacklist {{{ KERNMODULE }}}" >> /usr/lib/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
