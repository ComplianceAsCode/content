#!/bin/bash
source ./kernel_module_preparation.sh
kernel_module_preparation "fire-wire"

MODULES_DIR="/etc/modules-load.d"
mkdir -p "$MODULES_DIR"
echo "install sctp /bin/false" >> "$MODULES_DIR/fire-wire.conf"
