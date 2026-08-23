#!/bin/bash
set -xe

echo "installing cluster-logging-operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-install.yaml

sleep 30

echo "waiting for cluster-logging-operator deployment to exist"
while [ -z "$(oc get -n openshift-logging --ignore-not-found deployment/cluster-logging-operator)" ]; do
    sleep 3
done

echo "waiting for cluster-logging-operator deployment to be ready"
oc wait -n openshift-logging --for=condition=Available  --timeout=120s \
    deployment/cluster-logging-operator

echo "installing clusterlogging instance"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-instance.yaml

echo "installing clusterlogforwarder instance"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/forward-logs.yaml
