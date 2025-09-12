#!/bin/bash
set -xe

export CLO_CHANNEL=$(oc get packagemanifest -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}' -n openshift-marketplace cluster-logging | sort | tail -1)

if [ "${CLO_CHANNEL}" =~ stable-6\.* ]; then
    echo "OCP ${ocp_version} has CLO 6.0 is available for install";
    install_v6=true
fi

echo "installing cluster-logging-operator from channel ${CLO_CHANNEL}"
if [ "$install_v6" = true ] ; then
    envsubst < <(cat ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-install-observability.yaml) | oc apply -f
else
    envsusbst < <(cat ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-install.yaml) | oc apply -f
fi

sleep 30

echo "waiting for cluster-logging-operator deployment to exist"
while [ -z "$(oc get -n openshift-logging --ignore-not-found deployment/cluster-logging-operator)" ]; do
    sleep 3
done

echo "waiting for cluster-logging-operator deployment to be ready"
oc wait -n openshift-logging --for=condition=Available  --timeout=120s \
    deployment/cluster-logging-operator

if [ "$install_v6" = true ] ; then
    echo "installing clusterlogforwarder 6.0"
    oc apply -f ${ROOT_DIR}/ocp-resources/e2e/forward-logs-observability.yaml
else
    echo "installing clusterlogging instance"
    oc apply -f ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-instance.yaml

    echo "installing clusterlogforwarder instance"
    oc apply -f ${ROOT_DIR}/ocp-resources/e2e/forward-logs.yaml
fi
