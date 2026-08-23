#!/bin/bash
set -xe

echo "Mimicking the behavior of a deployed scanner"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/acs-sensor-install.yaml --server-side=true

sleep 30

echo "waiting for gitops deployment to exist"
while [ -z "$(oc wait -n stackrox --for=condition=Available  --timeout=300s deployment/sensor)" ]; do
    sleep 3
done

echo "waiting for gitops deployment to be ready"
oc wait -n stackrox --for=condition=Available  --timeout=300s \
    deployment/sensor
