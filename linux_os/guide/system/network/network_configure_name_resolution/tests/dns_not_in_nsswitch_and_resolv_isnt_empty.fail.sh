#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# remediation = none

source common.sh

echo -e "nameserver 192.168.1.2\nnameserver 192.168.1.3\n" >> "$RESOLVFILE"
