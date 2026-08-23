#!/bin/bash

# remediation = none

mkdir -p /kubernetes-api-resources/apis/config.openshift.io/v1/apiservers

cat << EOF > /kubernetes-api-resources/apis/config.openshift.io/v1/apiservers/cluster
spec:
    tlsSecurityProfile:
        custom:
            ciphers:
            - ECDHE-ECDSA-CHACHA20-POLY1305
            - ECDHE-RSA-AES128-GCM-SHA256
            minTLSVersion: VersionTLS11
        type: Custom
EOF
