#!/bin/bash

mkdir -p /tmp/apis/config.openshift.io/v1/images

cat << EOF > /tmp/apis/config.openshift.io/v1/images/cluster
spec:
  allowedRegistriesForImport:
  - domainName: test.secure-registry.ocp.e2e.com
    insecure: false

EOF
