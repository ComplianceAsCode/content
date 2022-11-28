#!/bin/bash

# remediation = none

mkdir -p /kubernetes-api-resources/apis/operator.openshift.io/v1/namespaces/openshift-ingress-operator/ingresscontrollers

cat << EOF > /kubernetes-api-resources/apis/operator.openshift.io/v1/namespaces/openshift-ingress-operator/ingresscontrollers/default
spec:
     tlsSecurityProfile:
         intermediate: {}
         type: Intermediate
EOF
