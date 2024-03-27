#!/bin/bash
# remediation = none
# packages = jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/apis/rbac.authorization.k8s.io/v1"
crb_apipath="/apis/rbac.authorization.k8s.io/v1/clusterrolebindings?limit=10000"

cat <<EOF > "$kube_apipath$crb_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRoleBinding",
            "metadata": {
                "creationTimestamp": "2023-11-07T10:07:21Z",
                "labels": {
                    "app": "controller.csi.trident.netapp.io",
                    "k8s_version": "v1.25.14",
                    "trident_version": "v23.01.0"
                },
                "name": "trident-controller",
                "ownerReferences": [
                    {
                        "apiVersion": "trident.netapp.io/v1",
                        "controller": true,
                        "kind": "TridentOrchestrator",
                        "name": "trident",
                        "uid": "eb7fe92c-3378-4d27-98a1-d4b543772e3c"
                    }
                ],
                "resourceVersion": "989379693",
                "uid": "8eab8cd7-8fc3-41a7-bd2a-1c9f6f7c2d8b"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "trident-controller"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "trident-controller",
                    "namespace": "trident"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRoleBinding",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "false"
                },
                "creationTimestamp": "2021-01-04T14:30:26Z",
                "labels": {
                    "app.kubernetes.io/instance": "roles"
                },
                "name": "self-provisioners",
                "resourceVersion": "268316753",
                "uid": "7c5ad812-cab1-40bb-88dc-a014015f7ede"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "self-provisioner"
            }
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRoleBinding",
            "metadata": {
                "creationTimestamp": "2021-01-04T14:49:26Z",
                "name": "prometheus-k8s",
                "resourceVersion": "39547",
                "uid": "57de031f-a360-483d-903f-19f0fb597cc9"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "prometheus-k8s"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "prometheus-k8s",
                    "namespace": "openshift-monitoring"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRoleBinding",
            "metadata": {
                "creationTimestamp": "2021-01-04T14:27:59Z",
                "name": "system:openshift:openshift-apiserver",
                "resourceVersion": "5623",
                "uid": "fe1c3593-7e89-4b2c-b47b-a6569f47d88f"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "cluster-admin"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "openshift-apiserver-sa",
                    "namespace": "openshift-apiserver"
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
EOF

jq_filter='[.items[] | select ( .subjects[]?.name == "default" ) | select(.subjects[].namespace | startswith("kube-") or startswith("openshift-") | not) | .metadata.name ] | unique'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$crb_apipath#$(echo -n "$crb_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$crb_apipath" > "$filteredpath"
