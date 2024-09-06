#!/bin/bash



# Deploy a resource quota for e2e-test namespace, this namespace is created by the e2e-remediation.sh script
# under the applications/openshift/networking/configure_network_policies_namespaces/tests/ocp4/e2e-remediation.sh
# let's create a new project anyway because this could run before the other script
cat << EOF | oc apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: e2e-test
EOF

cat << EOF | oc apply -n e2e-test -f -
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: e2e-test-namespace-quotas
spec:
  hard:
    count/daemonsets.apps: "0"
    count/deployments.apps: "0"
    limits.cpu: "0"
    limits.memory: "0"
    pods: "0"
EOF
