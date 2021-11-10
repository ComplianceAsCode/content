#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"


# Create infra file for CPE to pass
mkdir -p "$kube_apipath/api/v1/namespaces/openshift-etcd/configmaps"
etcd_config_apipath="/api/v1/namespaces/openshift-etcd/configmaps/etcd-pod"
cat <<EOF > "$kube_apipath/api/v1/namespaces/openshift-etcd/configmaps/etcd-pod"
{
    "apiVersion": "v1",
    "data": {
        "forceRedeploymentReason": "",
        "pod.yaml": "{
          \"name\": \"ETCD_CIPHER_SUITES\",
          \"value\": \"NO SUITES\"
        }"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2021-10-14T03:46:27Z",
        "name": "etcd-pod",
        "namespace": "openshift-etcd",
        "resourceVersion": "5792",
        "uid": "73939ea6-e6a4-4ee4-8aa8-775170945431"
    }
}
EOF

# Get file path. This will actually be read by the scan
filepath="$kube_apipath$etcd_config_apipath#$(echo -n "$etcd_config_apipath" | sha256sum | awk '{print $1}')"
