#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
source ./kernel_module_preparation.sh
kernel_module_preparation "fire-wire"

MODULES_DIR="/etc/modules-load.d"
mkdir -p "$MODULES_DIR"
echo "install sctp /bin/false" >> "$MODULES_DIR/fire-wire.conf"
