#!/bin/bash

if ! [ -f "/etc/grub2.cfg" ]; then
    touch /etc/grub2.cfg
fi
if ! [ -d "/etc/grub.d" ]; then
    mkdir -p /etc/grub.d
fi
echo "selinux=0" > /etc/grub.d/tmp_file
echo "enforcing=0" >> /etc/grub.d/tmp_file
GRUB_FILES=(/etc/default/grub /etc/grub2.cfg)
for file in "${GRUB_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sed -i --follow-symlinks "s/selinux=0//gI" "$file"
        sed -i --follow-symlinks "s/enforcing=0//gI" "$file"
    fi
done
