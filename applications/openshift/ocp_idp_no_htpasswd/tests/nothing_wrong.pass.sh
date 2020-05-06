#!/bin/bash

mkdir -p /tmp/apis/config.openshift.io/v1/oauths

cat << EOF > /tmp/apis/config.openshift.io/v1/oauths/cluster
spec:
   nothing: here
EOF
