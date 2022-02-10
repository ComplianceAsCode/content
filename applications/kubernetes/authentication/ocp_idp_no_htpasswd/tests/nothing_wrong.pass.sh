#!/bin/bash

mkdir -p /kubernetes-api-resources/apis/config.openshift.io/v1/oauths

cat << EOF > /kubernetes-api-resources/apis/config.openshift.io/v1/oauths/cluster
spec:
   nothing: here
EOF
