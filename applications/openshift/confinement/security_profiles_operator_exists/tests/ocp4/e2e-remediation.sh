#!/bin/bash
set -xe

echo "installing security profiles operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/spo-install.yaml --server-side=true

sleep 30

echo "waiting for security-profiles-operator deployment to exist"
while [ -z "$(oc wait -n openshift-security-profiles --for=condition=Available  --timeout=300s deployment/security-profiles-operator)" ]; do
    sleep 3
done

echo "waiting for security-profiles-operator deployment to be ready"
oc wait -n openshift-security-profiles --for=condition=Available  --timeout=300s \
    deployment/security-profiles-operator

echo "waiting the subscription to have .status.installedCSV"
while [ -z "$(oc get subscription security-profiles-operator -nopenshift-security-profiles -o jsonpath='{.status.installedCSV}')" ]; do
    sleep 3
done
