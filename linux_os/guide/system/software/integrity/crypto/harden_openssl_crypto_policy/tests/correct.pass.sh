#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

configfile=/etc/crypto-policies/back-ends/opensslcnf.config

echo "Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256" > "$configfile"
