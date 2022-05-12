#!/bin/bash

# Paths to configuration files and directories for modprobe
kernel_mod_files=( "/etc/modprobe.d/*.conf" "/etc/modprobe.conf" "/etc/modules-load.d/*.conf" "/run/modules-load.d/*.conf" "/usr/lib/modules-load.d/*.conf" "/run/modprobe.d/*.conf" "/usr/lib/modprobe.d/*.conf" )
for filename in "${kernel_mod_files[@]}"; do
    for file in $filename; do
        if [[ -f $file ]]; then
            sed -i '/install {{{ KERNMODULE }}}/d' $file
            echo "# install {{{ KERNMODULE }}} /bin/true" > $file
        fi
    done
done
