#!/bin/bash

# make sure that the option is overridden through boot parameter
{{% if product == "rhel8" %}}
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) random.trust_cpu=off"
{{% else %}}
grubby --update-kernel=ALL --args="random.trust_cpu=off"
{{% endif %}}

if grep -q CONFIG_RANDOM_TRUST_CPU /boot/config-`uname -r`; then
    sed -Ei 's/(.*)CONFIG_RANDOM_TRUST_CPU=.(.*)/\1CONFIG_RANDOM_TRUST_CPU=y\2/' /boot/config-`uname -r`
else
    echo "CONFIG_RANDOM_TRUST_CPU=y" >> /boot/config-`uname -r`
fi
