#!/bin/bash

cat << EOF > /tmp/idp.yaml
spec:
  identityProviders:
  - foo: bar
    type: LDAP
  - bar: baz
    type: something
EOF
