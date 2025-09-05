#!/bin/bash

# we are using an existing default secret name for testing, so it won't cause any subsequent failures on testing routes.
oc patch ingresscontroller.operator default --type merge -p '{"spec":{"defaultCertificate":{"name":"router-certs-default"}}}' -n openshift-ingress-operator
