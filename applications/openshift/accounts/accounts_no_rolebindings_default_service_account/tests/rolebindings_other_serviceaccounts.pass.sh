#!/bin/bash
# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/apis/rbac.authorization.k8s.io/v1"
crb_apipath="/apis/rbac.authorization.k8s.io/v1/rolebindings?limit=10000"

# This file assumes that we dont have any rolebindings.
cat <<EOF > "$kube_apipath$crb_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Allows deploymentconfigs in this namespace to rollout pods in this namespace.  It is auto-managed by a controller; remove subjects to disable."
                },
                "creationTimestamp": "2021-01-06T13:19:28Z",
                "name": "system:deployers",
                "namespace": "trident",
                "resourceVersion": "843465",
                "uid": "3399b7c0-d962-4ad8-8de4-c04dab0dfd2b"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "system:deployer"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "deployer",
                    "namespace": "trident"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Allows builds in this namespace to push images to this namespace.  It is auto-managed by a controller; remove subjects to disable."
                },
                "creationTimestamp": "2021-01-06T13:19:28Z",
                "name": "system:image-builders",
                "namespace": "trident",
                "resourceVersion": "843464",
                "uid": "58fe54b0-4954-4d65-a479-a4e19853df37"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "system:image-builder"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "builder",
                    "namespace": "trident"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Allows all pods in this namespace to pull images from this namespace.  It is auto-managed by a controller; remove subjects to disable."
                },
                "creationTimestamp": "2021-01-06T13:19:28Z",
                "name": "system:image-pullers",
                "namespace": "trident",
                "resourceVersion": "843445",
                "uid": "3e83e155-123b-4b83-af19-22e996f7b96f"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "ClusterRole",
                "name": "system:image-puller"
            },
            "subjects": [
                {
                    "apiGroup": "rbac.authorization.k8s.io",
                    "kind": "Group",
                    "name": "system:serviceaccounts:trident"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "creationTimestamp": "2023-11-07T10:07:21Z",
                "labels": {
                    "app": "controller.csi.trident.netapp.io"
                },
                "name": "trident-controller",
                "namespace": "trident",
                "ownerReferences": [
                    {
                        "apiVersion": "trident.netapp.io/v1",
                        "controller": true,
                        "kind": "TridentOrchestrator",
                        "name": "trident",
                        "uid": "eb7fe92c-3378-4d27-98a1-d4b543772e3c"
                    }
                ],
                "resourceVersion": "989379714",
                "uid": "80a292a1-660e-41e2-91f9-3a6758b68b06"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "Role",
                "name": "trident-controller"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "trident-controller"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "creationTimestamp": "2023-10-05T11:21:08Z",
                "labels": {
                    "app": "node.csi.trident.netapp.io"
                },
                "name": "trident-node-linux",
                "namespace": "trident",
                "ownerReferences": [
                    {
                        "apiVersion": "trident.netapp.io/v1",
                        "controller": true,
                        "kind": "TridentOrchestrator",
                        "name": "trident",
                        "uid": "eb7fe92c-3378-4d27-98a1-d4b543772e3c"
                    }
                ],
                "resourceVersion": "947943755",
                "uid": "f53187bd-4a6d-4ce8-9469-66e4f0fbb0c1"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "Role",
                "name": "trident-node-linux"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "trident-node-linux"
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


jq_filter='[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select ( .subjects[]?.name == "default" ) | .metadata.namespace + "/" + .metadata.name ] | unique'
# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$crb_apipath#$(echo -n "$crb_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$crb_apipath" > "$filteredpath"
