#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Red Hat Enterprise Linux 8

configfile=/etc/crypto-policies/back-ends/opensslcnf.config

echo "#MinProtocol = TLSv1.2" > "$configfile"
echo "#MinProtocol = DTLSv1.2" >> "$configfile"
