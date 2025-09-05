#!/bin/bash
set -xe

ocp_version=$(oc version -ojson | jq -r '.openshiftVersion')
clo_v6_available_from="4.14.0"

if [ "$(printf '%s\n' "$ocp_version" "$clo_v6_available_from" | sort -V | head -n1)" = "$clo_v6_available_from" ]; then
    echo "OCP ${ocp_version} has CLO 6.0 is available for install";
    install_v6=true
fi

if [ "$install_v6" = true ] ; then
    echo "installing cluster-logging-operator V6.0"
    oc apply -f ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-install-observability.yaml
else
    echo "installing cluster-logging-operator"
    oc apply -f ${ROOT_DIR}/ocp-resources/e2e/cluster-logging-install.yaml
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
