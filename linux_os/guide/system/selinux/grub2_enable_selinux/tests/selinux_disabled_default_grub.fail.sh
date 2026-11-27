#!/bin/bash

if ! [ -f "/etc/grub2.cfg" ]; then
    touch /etc/grub2.cfg
fi
if ! [ -d "/etc/default" ]; then
    mkdir -p /etc/default
fi

echo "GRUB_CMDLINE_LINUX=selinux=0 enforcing=0 audit=1" >> /etc/default/grub
GRUB_FILES=(/etc/grub2.cfg )
GRUB_FILES+=($(ls /etc/grub.d/* 2>/dev/null))
for file in "${GRUB_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        sed -i --follow-symlinks "s/selinux=0//gI" "$file"
        sed -i --follow-symlinks "s/enforcing=0//gI" "$file"
    fi
done
