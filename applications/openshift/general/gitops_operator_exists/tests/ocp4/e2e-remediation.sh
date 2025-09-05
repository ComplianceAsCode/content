#!/bin/bash
set -xe

echo "installing gitops operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/gitops-operator-install.yaml --server-side=true

sleep 30

echo "waiting for gitops deployment to exist"
while [ -z "$(oc wait -n openshift-gitops --for=condition=Available  --timeout=300s deployment/cluster)" ]; do
    sleep 3
done

echo "waiting for gitops deployment to be ready"
oc wait -n openshift-gitops --for=condition=Available  --timeout=300s \
    deployment/cluster

