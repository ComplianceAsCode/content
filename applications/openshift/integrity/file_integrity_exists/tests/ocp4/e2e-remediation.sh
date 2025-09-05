#!/bin/bash
set -xe

echo "installing file-integrity-operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/file-integrity-install.yaml

sleep 30

echo "waiting for file-integrity-operator deployment to exist"
while [ -z "$(oc get -n openshift-file-integrity --ignore-not-found deployment/file-integrity-operator)" ]; do
    sleep 3
done

echo "waiting for file-integrity-operator deployment to be ready"
oc wait -n openshift-file-integrity --for=condition=Available  --timeout=120s \
    deployment/file-integrity-operator

echo "installing file-integrity instance"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/file-integrity-instance.yaml
