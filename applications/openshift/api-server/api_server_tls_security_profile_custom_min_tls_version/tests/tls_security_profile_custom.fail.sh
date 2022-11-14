#!/bin/bash

mkdir -p /tmp/apis/config.openshift.io/v1/apiservers

cat << EOF > /tmp/apis/config.openshift.io/v1/apiservers/cluster
spec:
    tlsSecurityProfile:
        custom:
            ciphers:
            - ECDHE-ECDSA-CHACHA20-POLY1305
            - ECDHE-RSA-AES128-GCM-SHA256
            minTLSVersion: VersionTLS11
        type: Custom
EOF
