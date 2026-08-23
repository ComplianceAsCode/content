#!/bin/bash
set -xe

echo "installing container security operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/container-security-operator-install.yaml --server-side=true

sleep 30

echo "waiting for container-security-operator deployment to exist"
while [ -z "$(oc get --ignore-not-found deploy -nopenshift-operators container-security-operator)" ]; do
    sleep 3
done

echo "waiting for container-security-operator deployment to be ready"
oc wait -nopenshift-operators --for=condition=Available  --timeout=300s \
    deployment/container-security-operator

echo "waiting the subscription to have .status.installedCSV"
while [ -z "$(oc get subscription container-security-operator -nopenshift-operators -o jsonpath='{.status.installedCSV}')" ]; do
    sleep 3
done
