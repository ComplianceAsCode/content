#!/bin/bash

# Reuse an existing certificate so we don't have to regenerate one.
oc get secrets -n openshift-ingress-operator router-ca -o json | jq '.data."tls.crt"' | tr -d '"' | base64 -d > /tmp/ca-tls.crt

# Create it in the openshift-config namespace. If we don't do this, the
# machineconfig cluster operator will fail to find it and eventually go into a
# degraded state.
oc create configmap custom-trusted-ca-bundle -n openshift-config --from-file=ca-bundle.crt=/tmp/ca-tls.crt

# Update the trustedCA to point to the new configmap. This is effectively the
# remediation we're checking for.
oc patch proxies.config cluster --type merge -p '{"spec":{"trustedCA":{"name":"custom-trusted-ca-bundle"}}}'

# This will bounce a bunch of the clusteroperators. Let's make sure they're all
# stable for a couple of minutes before moving on.
oc adm wait-for-stable-cluster --minimum-stable-period 2m
