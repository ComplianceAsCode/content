#!/bin/bash

# remediation = none

mkdir -p /tmp/apis/config.openshift.io/v1/images

cat << EOF > /tmp/apis/config.openshift.io/v1/images/cluster
spec:
  allowedRegistriesForImport:
  - domainName: test.insecure-registry.ocp.e2e.com
    insecure: true
EOF
