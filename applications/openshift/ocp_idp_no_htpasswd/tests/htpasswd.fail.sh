#!/bin/bash

# remediation = none

mkdir -p /tmp/apis/config.openshift.io/v1/oauths

cat << EOF > /tmp/apis/config.openshift.io/v1/oauths/cluster
spec:
  identityProviders:
  - foo: bar
    type: LDAP
  - bar: baz
    type: HTPasswd
EOF
