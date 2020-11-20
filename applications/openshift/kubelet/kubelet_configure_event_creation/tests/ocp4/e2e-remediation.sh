#!/bin/bash
set -xe

# Test only on workers for speed.
echo "applying eventRecordQPS"
cat << EOF | oc apply --server-side -f -
---
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: worker-configure-event-limit
spec:
  machineConfigPoolSelector:
    matchLabels:
      pools.operator.machineconfiguration.openshift.io/worker: ""
  kubeletConfig:
    eventRecordQPS: 10
EOF

sleep 30

echo "waiting for workers to update"
while true; do
    status=$(oc get mcp/worker | grep worker | awk '{ print $3 $4 }')
    if [ "$status" == "TrueFalse" ]; then
      break
    fi
    sleep 1
done

exit 0
