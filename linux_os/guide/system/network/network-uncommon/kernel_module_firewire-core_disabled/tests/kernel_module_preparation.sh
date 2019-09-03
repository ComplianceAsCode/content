#!/bin/bash

# Kernel module can be disabled in different files.
# This function prepares environment for testing - it deletes all
# occurrences of specified module.
# Parameters: $1 - name of kernel module
function kernel_module_preparation() {
        if [ -z "$1" ]; then
                echo "Please specify kernel module."
                echo "Usage: prepare_kernel_module MODULE"
                exit 1
        fi

        local MODULE=$1

        # Paths to configuration files and directories for modprobe
        kernel_mod_files=( "/etc/modprobe.d/*.conf" "/etc/modprobe.conf" "/etc/modules-load.d/*.conf" "/run/modules-load.d/.*conf" "/usr/lib/modules-load.d/*.conf" "/run/modprobe.d/*.conf" "/usr/lib/modprobe.d/*.conf" )

        for filename in "${kernel_mod_files[@]}"; do
                for file in $filename; do
                        sed -i "/install[[:space:]]+$kern_module/d" $file
                done
        done
}
