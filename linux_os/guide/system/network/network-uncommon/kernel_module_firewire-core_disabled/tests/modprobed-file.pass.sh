#!/bin/bash
source ./kernel_module_preparation.sh
kernel_module_preparation "fire-wire"

MODULES_DIR="/etc/modprobe.d"
mkdir -p "$MODULES_DIR"
echo "install firewire-core /bin/true" >> "$MODULES_DIR/firewire.conf"
