#!/bin/bash

mkdir -p /tmp/apis/config.openshift.io/v1/images

cat << EOF > /tmp/apis/config.openshift.io/v1/images/cluster
spec:
  registrySources:
    allowedRegistries:
    - test.trusted-registry.ocp.e2e.com
EOF
