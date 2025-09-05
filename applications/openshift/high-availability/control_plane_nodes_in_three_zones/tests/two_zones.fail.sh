#!/bin/bash
# remediation = none
# packages = jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/api/v1"
nodes_apipath="/api/v1/nodes"

cat <<EOF > "$kube_apipath$nodes_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "Node",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/controlPlaneTopology": "HighlyAvailable",
                    "machineconfiguration.openshift.io/currentConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/lastAppliedDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/reason": "",
                    "machineconfiguration.openshift.io/ssh": "accessed",
                    "machineconfiguration.openshift.io/state": "Done",
                    "volumes.kubernetes.io/controller-managed-attach-detach": "true"
                },
                "creationTimestamp": "2023-01-04T14:23:02Z",
                "labels": {
                    "beta.kubernetes.io/arch": "amd64",
                    "beta.kubernetes.io/os": "linux",
                    "kubernetes.io/arch": "amd64",
                    "kubernetes.io/hostname": "ocp-control1.domain.local",
                    "kubernetes.io/os": "linux",
                    "node-role.kubernetes.io/master": "",
                    "node.openshift.io/os_id": "rhcos",
                    "topology.kubernetes.io/region": "eu-central-1",
                    "topology.kubernetes.io/zone": "eu-central-1a"
                },
                "name": "ocp-control1.domain.local",
                "resourceVersion": "1192119588",
                "uid": "c0aa2f3d-71ed-428d-9d11-4824f0e914da"
            },
            "spec": {
                "podCIDR": "10.128.0.0/24",
                "podCIDRs": [
                    "10.128.0.0/24"
                ],
                "taints": [
                    {
                        "effect": "NoSchedule",
                        "key": "node-role.kubernetes.io/master"
                    }
                ]
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Node",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/controlPlaneTopology": "HighlyAvailable",
                    "machineconfiguration.openshift.io/currentConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/lastAppliedDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/reason": "",
                    "machineconfiguration.openshift.io/ssh": "accessed",
                    "machineconfiguration.openshift.io/state": "Done",
                    "volumes.kubernetes.io/controller-managed-attach-detach": "true"
                },
                "creationTimestamp": "2023-01-04T14:24:11Z",
                "labels": {
                    "beta.kubernetes.io/arch": "amd64",
                    "beta.kubernetes.io/os": "linux",
                    "kubernetes.io/arch": "amd64",
                    "kubernetes.io/hostname": "ocp-control2.domain.local",
                    "kubernetes.io/os": "linux",
                    "node-role.kubernetes.io/master": "",
                    "node.openshift.io/os_id": "rhcos",
                    "topology.kubernetes.io/region": "eu-central-1",
                    "topology.kubernetes.io/zone": "eu-central-1a"
                },
                "name": "ocp-control2.domain.local",
                "resourceVersion": "1192119593",
                "uid": "33735f94-a745-4d7d-8707-73df67cbc8e1"
            },
            "spec": {
                "podCIDR": "10.128.1.0/24",
                "podCIDRs": [
                    "10.128.1.0/24"
                ],
                "taints": [
                    {
                        "effect": "NoSchedule",
                        "key": "node-role.kubernetes.io/master"
                    }
                ]
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Node",
            "metadata": {
                "annotations": {
                    "machineconfiguration.openshift.io/controlPlaneTopology": "HighlyAvailable",
                    "machineconfiguration.openshift.io/currentConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredConfig": "rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/desiredDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/lastAppliedDrain": "uncordon-rendered-master-d0a23f1409780adbe3913473e3e42154",
                    "machineconfiguration.openshift.io/reason": "",
                    "machineconfiguration.openshift.io/state": "Done",
                    "volumes.kubernetes.io/controller-managed-attach-detach": "true"
                },
                "creationTimestamp": "2023-01-04T14:25:24Z",
                "labels": {
                    "beta.kubernetes.io/arch": "amd64",
                    "beta.kubernetes.io/os": "linux",
                    "kubernetes.io/arch": "amd64",
                    "kubernetes.io/hostname": "ocp-control3.domain.local",
                    "kubernetes.io/os": "linux",
                    "node-role.kubernetes.io/master": "",
                    "node.openshift.io/os_id": "rhcos",
                    "topology.kubernetes.io/region": "eu-central-1",
                    "topology.kubernetes.io/zone": "eu-central-1c"
                },
                "name": "ocp-control3.domain.local",
                "resourceVersion": "1192117923",
                "uid": "ffd0364a-b48d-4b53-bb69-47568e6511b5"
            },
            "spec": {
                "podCIDR": "10.128.2.0/24",
                "podCIDRs": [
                    "10.128.2.0/24"
                ],
                "taints": [
                    {
                        "effect": "NoSchedule",
                        "key": "node-role.kubernetes.io/master"
                    }
                ]
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
EOF

jq_filter='.items | map(select(.metadata.labels["node-role.kubernetes.io/master"] == "") | .metadata.labels["topology.kubernetes.io/zone"]) | unique | length'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$nodes_apipath#$(echo -n "$nodes_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$nodes_apipath" > "$filteredpath"
