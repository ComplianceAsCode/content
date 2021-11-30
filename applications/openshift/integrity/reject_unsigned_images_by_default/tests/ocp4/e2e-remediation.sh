#!/bin/bash
set -xe

echo "applying hardened policy.json"
oc apply --server-side -f ${ROOT_DIR}/ocp-resources/e2e/mc-hardened-policy-json.yaml

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
