#!/bin/bash


yum install -y jq

kube_filepath_root="/kubernetes-api-resources"
api_path="/apis/operator.openshift.io/v1/networks/cluster"
dir="$kube_filepath_root/apis/operator.openshift.io/v1/networks"
filepath="$kube_filepath_root$api_path"

mkdir -p "$dir"

jq_filter="[.spec.defaultNetwork.type]"

cat <<EOF > "$filepath"

{
    "apiVersion": "operator.openshift.io/v1",
    "kind": "Network",
    "metadata": {
        "creationTimestamp": "2022-04-25T13:39:15Z",
        "generation": 61,
        "name": "cluster",
        "resourceVersion": "24589",
        "uid": "089e8ee9-15c4-4868-80af-773df44cafdd"
    },
    "spec": {
        "clusterNetwork": [
            {
                "cidr": "10.128.0.0/14",
                "hostPrefix": 23
            }
        ],
        "defaultNetwork": {
            "type": "Calico"
        },
        "disableNetworkDiagnostics": false,
        "logLevel": "Normal",
        "managementState": "Managed",
        "observedConfig": null,
        "operatorLogLevel": "Normal",
        "serviceNetwork": [
            "172.30.0.0/16"
        ],
        "unsupportedConfigOverrides": null
    },
    "status": {
        "conditions": [
            {
                "lastTransitionTime": "2022-04-25T13:39:15Z",
                "status": "False",
                "type": "ManagementStateDegraded"
            },
            {
                "lastTransitionTime": "2022-04-25T13:52:19Z",
                "status": "False",
                "type": "Degraded"
            },
            {
                "lastTransitionTime": "2022-04-25T13:39:15Z",
                "status": "True",
                "type": "Upgradeable"
            },
            {
                "lastTransitionTime": "2022-04-25T13:53:53Z",
                "status": "False",
                "type": "Progressing"
            },
            {
                "lastTransitionTime": "2022-04-25T13:40:00Z",
                "status": "True",
                "type": "Available"
            }
        ],
        "readyReplicas": 0,
        "version": "4.10.6"
    }
}
EOF

# Get the filepath. This will actually be read by the scan.
filteredpath="$filepath#$(echo -n "$api_path$jq_filter" | sha256sum | awk '{print $1}')"

jq "$jq_filter" "$filepath" > "$filteredpath"
