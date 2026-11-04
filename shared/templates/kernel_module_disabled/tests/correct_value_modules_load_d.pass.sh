#!/bin/bash

echo "install {{{ KERNMODULE }}} /bin/true" > /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% if "ol" in families or 'rhel' in product or 'ubuntu' in product or 'suse' in families %}}
echo "blacklist {{{ KERNMODULE }}}" >> /etc/modules-load.d/{{{ KERNMODULE }}}.conf
{{% endif %}}
