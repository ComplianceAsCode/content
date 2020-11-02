#!/bin/bash

# remediation = none

mkdir -p /kubernetes-api-resources/apis/config.openshift.io/v1/oauths

cat << EOF > /kubernetes-api-resources/apis/config.openshift.io/v1/oauths/cluster
spec:
  identityProviders:
  - foo: bar
    type: LDAP
  - bar: baz
    type: HTPasswd
EOF
