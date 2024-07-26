#!/bin/bash

# Reuse an existing certificate so we don't have to regenerate one.
BUNDLE=$(oc get configmap -n openshift-apiserver trusted-ca-bundle -o json | jq '.data."ca-bundle.crt"')

# Create it in the openshift-config namespace. If we don't do this, the
# machineconfig cluster operator will fail to find it and eventually go into a
# degraded state.
cat << EOF | oc create -f -
apiVersion: v1
kind: ConfigMap
data:
  ca-bundle.crt: $BUNDLE
metadata:
  name: trusted-ca-bundle
  namespace: openshift-config
EOF

cat << EOF | oc create -f -
apiVersion: v1
kind: ConfigMap
data:
  ca-bundle.crt: $BUNDLE
metadata:
  name: trusted-ca-bundle
  namespace: openshift-config-managed
EOF

# Update the trustedCA to point to the new configmap. This is effectively the
# remediation we're checking for.
oc patch proxies.config cluster --type merge -p '{"spec":{"trustedCA":{"name":"trusted-ca-bundle"}}}'

# This will bounce a bunch of the clusteroperators. Let's make sure they're all
# stable for a couple of minutes before moving on.
oc adm wait-for-stable-cluster --minimum-stable-period 2m
