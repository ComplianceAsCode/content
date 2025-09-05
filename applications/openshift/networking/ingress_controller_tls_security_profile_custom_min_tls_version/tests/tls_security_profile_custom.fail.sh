#!/bin/bash

# remediation = none

mkdir -p /kubernetes-api-resources/apis/operator.openshift.io/v1/namespaces/openshift-ingress-operator/ingresscontrollers

cat << EOF > /kubernetes-api-resources/apis/operator.openshift.io/v1/namespaces/openshift-ingress-operator/ingresscontrollers/default
spec:
    tlsSecurityProfile:
        custom:
            ciphers:
            - ECDHE-ECDSA-CHACHA20-POLY1305
            - ECDHE-RSA-AES128-GCM-SHA256
            minTLSVersion: VersionTLS11
        type: Custom
EOF
