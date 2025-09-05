#!/bin/bash
set -xe

echo "applying sysctls"
oc apply --server-side -f ${ROOT_DIR}/ocp-resources/kubelet-sysctls-mc.yaml

sleep 30

echo "waiting for workers to update"
while true; do
    status=$(oc get mcp/worker | grep worker | awk '{ print $3 $4 }')
    if [ "$status" == "TrueFalse" ]; then
      break
    fi
    sleep 1
done

echo "waiting for masters to update"
while true; do
    status=$(oc get mcp/master | grep master | awk '{ print $3 $4 }')
    if [ "$status" == "TrueFalse" ]; then
      break
    fi
    sleep 1
done

echo "applying kubeletConfig"
oc apply --server-side -f ${ROOT_DIR}/ocp-resources/kubelet-config-mc.yaml

sleep 30

echo "waiting for workers to update"
while true; do
    status=$(oc get mcp/worker | grep worker | awk '{ print $3 $4 }')
    if [ "$status" == "TrueFalse" ]; then
      break
    fi
    sleep 1
done

echo "waiting for masters to update"
while true; do
    status=$(oc get mcp/master | grep master | awk '{ print $3 $4 }')
    if [ "$status" == "TrueFalse" ]; then
      break
    fi
    sleep 1
done

exit 0
