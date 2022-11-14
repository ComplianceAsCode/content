#!/bin/bash

mkdir -p /tmp/apis/config.openshift.io/v1/apiservers

cat << EOF > /tmp/apis/config.openshift.io/v1/apiservers/cluster
spec:
     tlsSecurityProfile:
         intermediate: {}
         type: Intermediate
EOF
