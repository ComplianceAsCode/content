#!/bin/bash

# remediation = none

mkdir -p /kubernetes-api-resources/apis/config.openshift.io/v1/apiservers

cat << EOF > /kubernetes-api-resources/apis/config.openshift.io/v1/apiservers/cluster
spec:
    tlsSecurityProfile:
        old: {}
        type: Old
EOF
