#!/bin/bash

# remediation = none

mkdir -p /apis/imageregistry.operator.openshift.io/v1/imagepruners/

cat << EOF > /apis/imageregistry.operator.openshift.io/v1/imagepruners/cluster
spec:
  suspend: true
  schedule: ""
  logLevel: "Normal"
EOF
