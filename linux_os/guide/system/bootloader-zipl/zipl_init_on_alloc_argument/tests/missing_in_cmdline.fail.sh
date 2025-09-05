#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9

# Make sure boot loader entries contain init_on_alloc=1
for file in /boot/loader/entries/*.conf
do
    if ! grep -q '^options.*init_on_alloc=1.*$' "$file" ; then
        sed -i '/^options / s/$/ init_on_alloc=1/' "$file"
    fi
done

# Make sure /etc/kernel/cmdline doesn't contain init_on_alloc=1
sed -Ei 's/(^.*)init_on_alloc=1(.*?)$/\1\2/' /etc/kernel/cmdline || true
