#!/bin/bash

# Convert - in firewire-core to _
kernmodule="firewire-core"
kernmodule_r="${kernmodule/-/_}"
echo "install ${kernmodule_r} /bin/true" > /etc/modprobe.d/"${kernmodule}".conf
{{% if product in ["fedora", "ol7", "ol8"] or "rhel" in product %}}
echo "blacklist ${kernmodule_r}" >> /etc/modprobe.d/"${kernmodule}".conf
{{% endif %}}
