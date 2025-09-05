#!/bin/bash

mkdir -p /apis/imageregistry.operator.openshift.io/v1/imagepruners/

cat << EOF > /apis/imageregistry.operator.openshift.io/v1/imagepruners/cluster
spec:
  suspend: false
  schedule: ""
  logLevel: "Normal"
EOF
