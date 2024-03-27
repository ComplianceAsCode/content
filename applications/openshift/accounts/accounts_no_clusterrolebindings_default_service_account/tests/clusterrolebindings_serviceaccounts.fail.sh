#!/bin/bash
# remediation = none
# packages = jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/apis/rbac.authorization.k8s.io/v1"
crb_apipath="/apis/rbac.authorization.k8s.io/v1/clusterrolebindings?limit=10000"

# This file assumes that we dont have any clusterrolebindings.
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
                "creationTimestamp": "2021-01-18T15:31:25Z",
                "name": "system:openshift:scc:anyuid",
                "resourceVersion": "5666124",
                "uid": "a85b6fd7-2d53-4e98-9c12-afc8d2e0896f"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "system:openshift:scc:anyuid"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "default",
                    "namespace": "app1"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRoleBinding",
            "metadata": {
                "creationTimestamp": "2021-08-10T10:35:31Z",
                "name": "ds-operator-manager-rolebinding",
                "resourceVersion": "1116129289",
                "uid": "0deb4996-a03c-4428-8135-5468cb218c8f"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "ds-operator-manager-role"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "default",
                    "namespace": "ds-system"
                },
                {
                    "kind": "ServiceAccount",
                    "name": "default",
                    "namespace": "magic-controller"
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
