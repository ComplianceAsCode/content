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
                "creationTimestamp": "2022-01-26T13:38:26Z",
                "name": "nexus-operator.v0.6.0",
                "namespace": "nexus",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v2",
                        "blockOwnerDeletion": false,
                        "controller": true,
                        "kind": "OperatorCondition",
                        "name": "nexus-operator.v0.6.0",
                        "uid": "762911b0-de01-46ca-8230-9fc68e0cb3c0"
                    }
                ],
                "resourceVersion": "268263243",
                "uid": "9059f140-d133-4c28-a62a-7b0c37ccdb75"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "Role",
                "name": "nexus-operator.v0.6.0"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "default"
                },
                {
                    "kind": "ServiceAccount",
                    "name": "default"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "creationTimestamp": "2022-01-26T13:38:27Z",
                "labels": {
                    "olm.owner": "nexus-operator.v0.6.0",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "nexus",
                    "operators.coreos.com/nexus-operator-m88i.nexus": ""
                },
                "name": "nexus-operator.v0.6.0-default-6b88497c67",
                "namespace": "nexus",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "nexus-operator.v0.6.0",
                        "uid": "7e146fba-7dcc-4f03-a2d1-b4e21978ca4c"
                    }
                ],
                "resourceVersion": "268263381",
                "uid": "b15ac38a-e9c2-4a98-bcc6-62ae3466ca5b"
            },
            "roleRef": {
                "apiGroup": "rbac.authorization.k8s.io",
                "kind": "Role",
                "name": "nexus-operator.v0.6.0-default-6b88497c67"
            },
            "subjects": [
                {
                    "kind": "ServiceAccount",
                    "name": "default",
                    "namespace": "nexus"
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "RoleBinding",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Allows deploymentconfigs in this namespace to rollout pods in this namespace.  It is auto-managed by a controller; remove subjects to disable."
                },
                "creationTimestamp": "2021-07-27T08:31:13Z",
                "name": "system:deployers",
                "namespace": "nexus",
                "resourceVersion": "114455275",
                "uid": "9806c445-5476-4f12-8ade-5078514aaaf9"
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
                    "namespace": "nexus"
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
                "creationTimestamp": "2021-07-27T08:31:13Z",
                "name": "system:image-builders",
                "namespace": "nexus",
                "resourceVersion": "114455272",
                "uid": "802555f7-136c-4739-b7cd-6d0c038acd8a"
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
                    "namespace": "nexus"
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
                "creationTimestamp": "2021-07-27T08:31:13Z",
                "name": "system:image-pullers",
                "namespace": "nexus",
                "resourceVersion": "114455261",
                "uid": "2980bbfd-ab40-4576-843c-864386deffa4"
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
                    "name": "system:serviceaccounts:nexus"
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
