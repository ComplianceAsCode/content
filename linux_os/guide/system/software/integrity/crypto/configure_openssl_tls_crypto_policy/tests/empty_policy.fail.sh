#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Red Hat Enterprise Linux 8
# remediation = none

configfile=/etc/crypto-policies/back-ends/opensslcnf.config

echo "minnothing =" > "$configfile"
