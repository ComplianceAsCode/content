#!/bin/bash
cat << EOF | oc apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: e2e-test
EOF
sleep 10
# Deploy a single NetworkPolicy per non control plane namespace
for NS in $(oc get namespaces -o json | jq -r '.items[] | select((.metadata.name | startswith("openshift") | not) and (.metadata.name | startswith("kube-") | not) and .metadata.name != "default") | .metadata.name'); do
cat << EOF | oc apply -n "$NS" -f -
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
EOF
done
