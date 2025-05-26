#!/bin/bash
set -xe

echo "installing sandboxed-containers-operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/sandboxed-containers-install.yaml --server-side=true

sleep 30

echo "waiting for sandboxed-containers-operator deployment to exist"
while [ -z "$(oc get -n openshift-sandboxed-containers-operator --ignore-not-found deployment/controller-manager)" ]; do
    sleep 3
done

echo "waiting for sandboxed-containers-operator deployment to be ready"
oc wait -n openshift-sandboxed-containers-operator --for=condition=Available  --timeout=300s \
    deployment/controller-manager
