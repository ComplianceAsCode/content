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
          \"value\": \"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256\"
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
