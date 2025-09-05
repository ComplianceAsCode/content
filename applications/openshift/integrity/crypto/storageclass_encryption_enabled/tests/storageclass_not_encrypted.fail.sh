#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

# Create infra file for CPE to pass
mkdir -p "$kube_apipath/apis/config.openshift.io/v1/infrastructures/"
cat <<EOF > "$kube_apipath/apis/config.openshift.io/v1/infrastructures/cluster"
{
    "apiVersion": "config.openshift.io/v1",
    "kind": "Infrastructure",
    "metadata": {
        "creationTimestamp": "2021-11-03T13:36:29Z",
        "generation": 1,
        "name": "cluster",
        "resourceVersion": "610",
        "uid": "d7cc2f22-766c-4aba-927f-24d3cc0f1c78"
    },
    "spec": {
        "cloudConfig": {
            "name": ""
        },
        "platformSpec": {
            "aws": {},
            "type": "AWS"
        }
    },
    "status": {
        "apiServerInternalURI": "https://api-int.ci-ln-p8l7xlb-76ef8.origin-ci-int-aws.dev.rhcloud.com:6443",
        "apiServerURL": "https://api.ci-ln-p8l7xlb-76ef8.origin-ci-int-aws.dev.rhcloud.com:6443",
        "controlPlaneTopology": "HighlyAvailable",
        "etcdDiscoveryDomain": "",
        "infrastructureName": "ci-ln-p8l7xlb-76ef8-jlqcw",
        "infrastructureTopology": "HighlyAvailable",
        "platform": "AWS",
        "platformStatus": {
            "aws": {
                "region": "us-east-2"
            },
            "type": "AWS"
        }
    }
}
EOF

storagev1="/apis/storage.k8s.io/v1"
storageclass_apipath="$storagev1/storageclasses"
# Create base file (not really needed for scanning but good for
# documentation and readability)
mkdir -p "$kube_apipath/$storagev1"
cat <<EOF > "$kube_apipath/$storageclass_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "allowVolumeExpansion": true,
            "apiVersion": "storage.k8s.io/v1",
            "kind": "StorageClass",
            "metadata": {
                "annotations": {
                    "storageclass.kubernetes.io/is-default-class": "true"
                },
                "creationTimestamp": "2021-11-03T13:38:43Z",
                "name": "gp2",
                "resourceVersion": "4189",
                "uid": "ef333e5a-0429-4494-a419-1398636e1c64"
            },
            "parameters": {
                "encrypted": "false",
                "type": "gp2"
            },
            "provisioner": "kubernetes.io/aws-ebs",
            "reclaimPolicy": "Delete",
            "volumeBindingMode": "WaitForFirstConsumer"
        },
        {
            "allowVolumeExpansion": true,
            "apiVersion": "storage.k8s.io/v1",
            "kind": "StorageClass",
            "metadata": {
                "creationTimestamp": "2021-11-03T13:38:54Z",
                "name": "gp2-csi",
                "resourceVersion": "5367",
                "uid": "22ee03a2-d248-4b16-86f1-2175a01d806f"
            },
            "parameters": {
                "encrypted": "true",
                "type": "gp2"
            },
            "provisioner": "ebs.csi.aws.com",
            "reclaimPolicy": "Delete",
            "volumeBindingMode": "WaitForFirstConsumer"
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

jq_filter='[.items[] | select (.provisioner == "kubernetes.io/aws-ebs" or .provisioner == "ebs.csi.aws.com")] | map(.parameters.encrypted)'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath/$storageclass_apipath#$(echo -n "$storageclass_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath/$storageclass_apipath" > "$filteredpath"
