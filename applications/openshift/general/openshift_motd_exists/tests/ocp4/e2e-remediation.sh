#!/bin/bash

cat << EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
 name: motd
 namespace: openshift
data:
  message: "This is an motd."
EOF