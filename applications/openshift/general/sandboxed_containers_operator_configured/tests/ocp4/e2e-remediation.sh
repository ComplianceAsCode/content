#!/bin/bash
set -xe

echo "installing sandboxed-containers-operator"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/sandboxed-containers-install.yaml --server-side=true

sleep 30

echo "waiting for sandboxed-containers-operator deployment to exist"
while [ -z "$(oc get -n openshift-sandboxed-containers-operator --ignore-not-found deployment/controller-manager)" ]; do
    sleep 3
done

# we need to wait for the pods to be ready, otherwise there is no webhook endpoint
# for the kataconfig
echo "waiting for sandboxed-containers-operator pods to be ready"
oc wait -n openshift-sandboxed-containers-operator --for=condition=ContainersReady=true \
--timeout=300s pods -l control-plane=controller-manager

echo "configuring kataconfig"
oc apply -f ${ROOT_DIR}/ocp-resources/e2e/sandboxed-containers-instance.yaml --server-side=true

while [ -z "$(oc get -n openshift-sandboxed-containers-operator --ignore-not-found machineconfigpool/kata-oc)" ]; do
    sleep 3
done

echo "check, that the mcp was updated"
oc wait --for=condition=Updated --timeout=3600s machineconfigpool/kata-oc

echo "waiting for the cluster to become stable"
oc adm wait-for-stable-cluster --minimum-stable-period 1m
