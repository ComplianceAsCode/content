#!/bin/bash
set -xe

echo "create a cluster resource quota"
cat << EOF | oc apply -f -
apiVersion: quota.openshift.io/v1
kind: ClusterResourceQuota
metadata:
  name: for-test-project
spec:
  quota:
    hard:
      pods: "10"
      secrets: "20"
  selector:
    annotations: null
    labels:
      matchLabels:
        name: test-project
EOF

while true; do 
    status=$(oc get clusterquota for-test-project -o=jsonpath='{.spec.quota.hard.pods}')
    if [ "$status" == "10" ]; then
        exit 0
    fi
    sleep 5
done