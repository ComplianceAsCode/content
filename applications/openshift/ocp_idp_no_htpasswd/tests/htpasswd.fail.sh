#!/bin/bash

# remediation = none

cat << EOF > /tmp/idp.yaml
spec:
  identityProviders:
  - foo: bar
    type: LDAP
  - bar: baz
    type: htpasswd
EOF
