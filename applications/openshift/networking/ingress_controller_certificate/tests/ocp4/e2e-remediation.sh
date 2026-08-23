#!/bin/bash

# Make a copy of existing router-certs-default secret to reuse it for testing, we can't just use it directly because it might get deleted when the defaultCertificate is set.
oc get secret router-certs-default -n openshift-ingress -o json | jq '.data."tls.crt"' | tr -d '"' | base64 -d > /tmp/ingress-tls.crt
oc get secret router-certs-default -n openshift-ingress -o json | jq '.data."tls.key"' | tr -d '"' | base64 -d > /tmp/ingress-tls.key
oc create secret tls router-certs-default-duplicate --cert=/tmp/ingress-tls.crt --key=/tmp/ingress-tls.key -n openshift-ingress

# Update the defaultCertificate to point to the new secret. This is effectively the remediation we're checking for.
# Note: we are using an existing default secret name for testing, so it won't cause any subsequent failures on testing routes.
oc patch ingresscontroller.operator default --type merge -p '{"spec":{"defaultCertificate":{"name":"router-certs-default-duplicate"}}}' -n openshift-ingress-operator
