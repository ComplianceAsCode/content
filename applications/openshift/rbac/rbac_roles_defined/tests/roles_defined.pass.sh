#!/bin/bash
# remediation = none

mkdir -p /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/
cat << EOF >> /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/roles?limit=1000
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "namespace": "default",
                "resourceVersion": "20019",
                "uid": "44dd03c2-c714-4608-89d9-a0b9a738e219"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:bootstrap-signer",
                "namespace": "kube-public",
                "resourceVersion": "219",
                "uid": "81750d07-993e-4b41-a76a-92fa48fcbf01"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "cluster-info"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:42:05Z",
                "name": "aws-creds-secret-reader",
                "namespace": "kube-system",
                "resourceVersion": "586",
                "uid": "4fefb8d9-ce41-4c51-a9fd-14eb6cdb005e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "aws-creds"
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "extension-apiserver-authentication-reader",
                "namespace": "kube-system",
                "resourceVersion": "212",
                "uid": "3b85d7a1-94d3-4612-a667-0ddd9be94ad6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "extension-apiserver-authentication"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "namespace": "kube-system",
                "resourceVersion": "20020",
                "uid": "22e94c6a-2747-4b94-895a-1dcb5a8e6272"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system::leader-locking-kube-controller-manager",
                "namespace": "kube-system",
                "resourceVersion": "217",
                "uid": "f5e8ca7f-1bdc-4488-a241-8900c823c420"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "kube-controller-manager"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system::leader-locking-kube-scheduler",
                "namespace": "kube-system",
                "resourceVersion": "218",
                "uid": "3df816ff-139e-4b4e-98c2-1a94eb6d0c07"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "kube-scheduler"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:bootstrap-signer",
                "namespace": "kube-system",
                "resourceVersion": "214",
                "uid": "a74d5949-849f-414d-a850-e339de6afb31"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:cloud-provider",
                "namespace": "kube-system",
                "resourceVersion": "215",
                "uid": "59a0a1d2-7a51-4c1d-864d-4c0d482cb625"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:41Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:token-cleaner",
                "namespace": "kube-system",
                "resourceVersion": "216",
                "uid": "0f129a23-1b35-4dc3-98d8-33dcdc4929a7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:54Z",
                "name": "system:openshift:leader-election-lock-kube-controller-manager",
                "namespace": "kube-system",
                "resourceVersion": "4915",
                "uid": "8fdcfa75-19bd-46e7-8a01-eab309ddf0af"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:leader-locking-openshift-controller-manager",
                "namespace": "kube-system",
                "resourceVersion": "4457",
                "uid": "5802b4b4-66fb-4c37-a153-b532780bba89"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "openshift-master-controllers"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:31Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-apiserver-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1070",
                "uid": "f2734192-9b11-4773-bb41-e21fd145de3d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:47:28Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-apiserver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "7300",
                "uid": "1d1204f1-ba14-4e66-99ce-f08fc9a05c67"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:29Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-authentication-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1013",
                "uid": "fa66bb35-de23-4fbd-8268-953c0cab89f7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:47:24Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-authentication",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "7175",
                "uid": "fcef1105-14e4-401d-b2e5-5f90cb8212c2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:39Z",
                "name": "cluster-cloud-controller-manager",
                "namespace": "openshift-cloud-controller-manager-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1292",
                "uid": "1c17439c-e24a-4fa8-8bd5-c6e55c26873d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "list",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:12Z",
                "name": "cloud-controller-manager",
                "namespace": "openshift-cloud-controller-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2127",
                "uid": "4caeb72a-677e-4533-8895-d55c3c7f1864"
            },
            "rules": [
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resourceNames": [
                        "cloud-controller-manager"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:46Z",
                "name": "cloud-credential-operator-role",
                "namespace": "openshift-cloud-credential-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1452",
                "uid": "692dcbb4-65be-4f29-aebd-3c1e2a4949e2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "configmaps",
                        "events",
                        "serviceaccounts",
                        "services"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:53:39Z",
                "name": "pod-identity-webhook",
                "namespace": "openshift-cloud-credential-operator",
                "resourceVersion": "13311",
                "uid": "f49cd16b-bbfe-4541-8fc2-3f087b18509e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "pod-identity-webhook"
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-cloud-credential-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "732",
                "uid": "2e89cb51-f06d-4853-b4a7-401885422524"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:56Z",
                "name": "aws-ebs-csi-driver-operator-role",
                "namespace": "openshift-cluster-csi-drivers",
                "resourceVersion": "5118",
                "uid": "166cfad0-debe-4044-a476-f7b46a4e7749"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints",
                        "persistentvolumeclaims",
                        "events",
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets",
                        "replicasets",
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:06Z",
                "name": "aws-ebs-csi-driver-prometheus",
                "namespace": "openshift-cluster-csi-drivers",
                "resourceVersion": "6060",
                "uid": "c7af239f-5983-4896-9272-ac33f9e37b92"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:33Z",
                "name": "machine-approver",
                "namespace": "openshift-cluster-machine-approver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1164",
                "uid": "67b32ffd-83ef-4944-b884-abcaceef6624"
            },
            "rules": [
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:31Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-cluster-machine-approver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1049",
                "uid": "3973e9c2-6ea9-4a4c-bc6e-3c3ef6c38e7a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespace/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:40Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-cluster-node-tuning-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1306",
                "uid": "5aef6731-2bbb-4815-b857-17745f2dd800"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:57Z",
                "name": "cluster-samples-operator",
                "namespace": "openshift-cluster-samples-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1749",
                "uid": "9c298b37-3f4e-4bfb-aedc-6901919b61d1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints",
                        "persistentvolumeclaims",
                        "events",
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets",
                        "replicasets",
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:57:07Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-cluster-samples-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "19370",
                "uid": "5861d3c0-b703-470b-a2fc-b6024cdcd7b2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:49Z",
                "name": "csi-snapshot-controller-leaderelection",
                "namespace": "openshift-cluster-storage-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1546",
                "uid": "860386bf-1a76-4f57-9e91-c0766bee1cd7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list",
                        "delete",
                        "update",
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus",
                "namespace": "openshift-cluster-storage-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "776",
                "uid": "9406385b-6b49-44e0-9d51-13adc0360fe6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-cluster-version",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "731",
                "uid": "341a76ff-ee24-490d-8185-bebc540d9581"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "name": "compliance-operator.v0.1.44",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v2",
                        "blockOwnerDeletion": false,
                        "controller": true,
                        "kind": "OperatorCondition",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "a8c9679f-1c59-46fd-a99f-4bc6508b4428"
                    }
                ],
                "resourceVersion": "40530",
                "uid": "765db1c4-0714-40f4-9ebd-1d92303a61e8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resourceNames": [
                        "compliance-operator.v0.1.44"
                    ],
                    "resources": [
                        "operatorconditions"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:35Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-api-resource-collector-54559d9cc",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40707",
                "uid": "821c5f93-8184-4178-a46c-30c757ab31ff"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-compliance-operator-69d8b8476",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40693",
                "uid": "2f8be8c2-8542-4d9d-adbd-9031754323b0"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims",
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "watch",
                        "create",
                        "get",
                        "list",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "configmaps",
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "patch",
                        "update",
                        "delete",
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "update",
                        "watch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "replicasets",
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "patch",
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resourceNames": [
                        "compliance-operator"
                    ],
                    "resources": [
                        "deployments/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "services/finalizers"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resourceNames": [
                        "compliance-operator"
                    ],
                    "resources": [
                        "deployments/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "delete",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamtags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:37Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-profileparser-7b67fb8967",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40699",
                "uid": "6b88ea52-4583-4bbc-8bbc-6fec36b0bd22"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles",
                        "profilebundles/status",
                        "profilebundles/finalizers"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles",
                        "rules",
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list",
                        "create",
                        "update",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:36Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-remediation-aggregator-8698f476cb",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40703",
                "uid": "585a4589-ae96-4ea4-892b-21541c8bcc8b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans/finalizers",
                        "compliancecheckresults/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations",
                        "complianceremediations/status"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:37Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-rerunner-5f6b65fc75",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40691",
                "uid": "13d3bc85-95b8-4e4a-8e08-ee76353fca32"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-resultscollector-7bcdcc8cf5",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40706",
                "uid": "e12a7c7e-9b82-406a-a0af-df9fa9eabe39"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:36Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-resultserver-5c9b4c7fc9",
                "namespace": "openshift-compliance",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "compliance-operator.v0.1.44",
                        "uid": "24b8d1f6-5db4-4662-bc03-ff4faf411948"
                    }
                ],
                "resourceVersion": "40712",
                "uid": "7638dfff-2a65-4975-bfb6-5250155e55ea"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "restricted"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:16Z",
                "name": "openshift-compliance-prometheus",
                "namespace": "openshift-compliance",
                "resourceVersion": "40392",
                "uid": "572b78be-bef7-4947-9d74-ce4edec4ae6d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:56Z",
                "name": "aws-ebs-csi-driver-operator-aws-config-role",
                "namespace": "openshift-config-managed",
                "resourceVersion": "5151",
                "uid": "5f879dc8-f71d-4153-8e66-2e492202be42"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:03Z",
                "name": "cluster-cloud-controller-manager",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1867",
                "uid": "4bcc1b9e-4c1e-4a8d-b78c-e0e6f85ce620"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:11Z",
                "name": "console-configmap-reader",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12066",
                "uid": "857e0e97-eaf2-47bd-b015-a00c48d3b2d7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:10Z",
                "name": "console-operator",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12064",
                "uid": "da7fae65-9379-443e-8251-e8c353af4797"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "console-public"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:10Z",
                "name": "console-public",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12065",
                "uid": "4ae59321-fa4a-4ad4-a780-0aaada13c0fc"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "console-public"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:10Z",
                "name": "insights-operator-etc-pki-entitlement",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2067",
                "uid": "4b449c55-b521-41ef-8e2d-faa1257097f6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "watch",
                        "list",
                        "delete",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "name": "machine-api-controllers",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2248",
                "uid": "15b1e637-65e0-4b74-b6be-b88601fd8e0d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:02Z",
                "name": "machine-approver",
                "namespace": "openshift-config-managed",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1836",
                "uid": "29639791-cdad-4f0e-a770-8e216efd2dff"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "csr-controller-ca"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:02Z",
                "name": "system:openshift:oauth-servercert-trust",
                "namespace": "openshift-config-managed",
                "resourceVersion": "5644",
                "uid": "94f0b8c2-0a23-49d5-b234-ab47a476c454"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "oauth-serving-cert"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:42Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-config-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1330",
                "uid": "257d0445-6583-4ce9-974f-918518aa67a5"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:59Z",
                "name": "cluster-cloud-controller-manager",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1794",
                "uid": "fc24e067-d32b-4d34-9e13-bcb66aad80b4"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:11Z",
                "name": "console-operator",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12067",
                "uid": "bde0ce47-b293-4889-89c5-d780530f0200"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:35Z",
                "name": "coreos-pull-secret-reader",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "9745",
                "uid": "882640cc-24cd-4d97-9f71-a34fbb7a9bec"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:03Z",
                "name": "ingress-operator",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1868",
                "uid": "30da0f8e-373d-45fa-8407-6154bf18edfc"
            },
            "rules": [
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:02Z",
                "name": "insights-operator",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1852",
                "uid": "cb62847a-44cd-4c7f-a146-c17c7fd5e3ce"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "pull-secret",
                        "support"
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "name": "machine-api-controllers",
                "namespace": "openshift-config",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2212",
                "uid": "0d0017ee-5ad3-4f3c-b6c7-57f150db2015"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:11Z",
                "name": "console-operator",
                "namespace": "openshift-console-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12070",
                "uid": "f8674940-3db9-4df8-877e-5bf5341b2c20"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:07Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-console-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12055",
                "uid": "5a8ddab6-3ae0-46b5-a928-da4816d0e07e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:11Z",
                "name": "console-user-settings-admin",
                "namespace": "openshift-console-user-settings",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12068",
                "uid": "c74bf4dd-ff6d-4812-a1d8-2ace36f1c58c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:37:18Z",
                "name": "user-settings-520db122-3e51-4a1e-a92c-fb7315d6526d-role",
                "namespace": "openshift-console-user-settings",
                "resourceVersion": "39723",
                "uid": "634d536d-baac-47b5-a83b-b6cc4e97b1c1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "user-settings-520db122-3e51-4a1e-a92c-fb7315d6526d"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:10Z",
                "name": "console-operator",
                "namespace": "openshift-console",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12063",
                "uid": "20f120bb-e648-4db1-94cf-48b44e9862ab"
            },
            "rules": [
                {
                    "apiGroups": [
                        "console.openshift.io"
                    ],
                    "resources": [
                        "consoles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "events",
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes",
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:03Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-console",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12009",
                "uid": "20c7ebe1-0061-4f3d-8ebf-33de462bc5a0"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:31Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-controller-manager-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1038",
                "uid": "6223526f-4a5b-41ad-b0ad-06600d63ef58"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-controller-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "7296",
                "uid": "13ef459c-9861-4ae3-b67d-f6bd6800dca1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:52Z",
                "name": "system:openshift:leader-locking-openshift-controller-manager",
                "namespace": "openshift-controller-manager",
                "resourceVersion": "4637",
                "uid": "4a77e412-7a33-48ac-90c8-5588f75785ec"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "openshift-master-controllers"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:40Z",
                "name": "dns-operator",
                "namespace": "openshift-dns-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1301",
                "uid": "83dbbbdf-324a-4438-8834-9f2231f335a7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints",
                        "events",
                        "configmaps"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "services"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:39Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-dns-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1272",
                "uid": "73007f9b-6328-49e2-af6c-519cdcc86122"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:10Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-dns",
                "resourceVersion": "6504",
                "uid": "8154ca94-d2ac-42f6-bbe9-aba53c8db0d6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:32Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-etcd-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1095",
                "uid": "3aeb0026-dfc1-499a-851a-38565cc48dd7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:17Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "namespace": "openshift-etcd",
                "resourceVersion": "20025",
                "uid": "3e2c9599-c196-4edd-a3da-c55c1f81c193"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:00Z",
                "name": "cluster-image-registry-operator",
                "namespace": "openshift-image-registry",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1820",
                "uid": "72c2efb8-afd6-4153-8b67-1bcb46d73bac"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "replicasets",
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:07Z",
                "name": "node-ca",
                "namespace": "openshift-image-registry",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1997",
                "uid": "a5939d21-de9b-42eb-8d7d-b87c7a323025"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:36Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-image-registry",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1211",
                "uid": "d4245b88-d40e-4fa0-b3de-557bb0a60785"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:sa-creating-openshift-controller-manager",
                "namespace": "openshift-infra",
                "resourceVersion": "4463",
                "uid": "c82625e1-1609-46f8-8c60-eb0c40618a2c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts/token"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:02Z",
                "name": "ingress-operator",
                "namespace": "openshift-ingress-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1841",
                "uid": "123d76ed-dba9-47ef-9cd4-6ca0c6165b5a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints",
                        "persistentvolumeclaims",
                        "events",
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "services"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-ingress-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "739",
                "uid": "577e464a-1dfd-47a3-a43b-df98b524c5f6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:56:18Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-ingress",
                "resourceVersion": "17093",
                "uid": "3ec303df-8729-4d85-a96e-099e36ada679"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:04Z",
                "name": "insights-operator",
                "namespace": "openshift-insights",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1922",
                "uid": "b08326da-8e5f-4f68-8347-6e83dba04fc2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "gather"
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:07Z",
                "name": "insights-operator-obfuscation-secret",
                "namespace": "openshift-insights",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1998",
                "uid": "832cc349-19b9-4385-9cb2-5254cde8867a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "watch",
                        "list",
                        "delete",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:12Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-insights",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2132",
                "uid": "921e28a9-97bd-4b58-9bf4-5f6d93b005fd"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-apiserver-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "735",
                "uid": "f996386c-4bac-4a5b-8bfa-2eca06133f57"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:59Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-apiserver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1773",
                "uid": "f11af58f-538e-436c-8e7a-7380459f698a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:25Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-controller-manager-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "733",
                "uid": "5a86335a-5a9b-445f-86ce-8a2b35b25385"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:56Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-controller-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1684",
                "uid": "891c1c77-8ff5-4ae3-bd11-d1d22f8cc4eb"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:54Z",
                "name": "system:openshift:leader-election-lock-cluster-policy-controller",
                "namespace": "openshift-kube-controller-manager",
                "resourceVersion": "4911",
                "uid": "c713b878-db78-4036-94a7-cb0864957fc1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:31Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-scheduler-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1016",
                "uid": "2aa88fb0-c1ac-444a-8ae5-d0cd73c54586"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:57Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-kube-scheduler",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1736",
                "uid": "e324c5ec-bf99-4004-b672-609c96243fa8"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:53Z",
                "name": "system:openshift:sa-listing-configmaps",
                "namespace": "openshift-kube-scheduler",
                "resourceVersion": "4836",
                "uid": "9dbeac1d-3bc1-421f-86c6-582187c93e75"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "labels": {
                    "k8s-addon": "cluster-autoscaler.addons.k8s.io",
                    "k8s-app": "cluster-autoscaler"
                },
                "name": "cluster-autoscaler",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2209",
                "uid": "57053096-bd04-45bf-b58a-bb138a7d6fc5"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "cluster-autoscaler-status"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:08Z",
                "name": "cluster-autoscaler-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2015",
                "uid": "b40c249b-1978-4f32-b53a-4fcae36dda28"
            },
            "rules": [
                {
                    "apiGroups": [
                        "autoscaling.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints",
                        "persistentvolumeclaims",
                        "events",
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets",
                        "replicasets",
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "cluster.k8s.io",
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machinedeployments",
                        "machinesets"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors",
                        "prometheusrules"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "name": "cluster-baremetal-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2252",
                "uid": "02d3ffed-091c-43c0-8cb9-c6ad4654d278"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets",
                        "services"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "name": "machine-api-controllers",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2258",
                "uid": "e089e9fa-4e75-4969-81c8-009f45736051"
            },
            "rules": [
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "healthchecking.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "list",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "baremetalhosts"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "baremetalhosts/status",
                        "baremetalhosts/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "name": "machine-api-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2286",
                "uid": "037bf85a-9a85-4036-9636-90bc7860f32e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "get",
                        "list",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "get",
                        "list",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "name": "prometheus-k8s-cluster-autoscaler-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2284",
                "uid": "2920c38f-ccc4-4444-80fa-642d06a717b4"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespace/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "name": "prometheus-k8s-cluster-baremetal-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2229",
                "uid": "46efa9c1-e3dd-4e52-beeb-e03304c000b0"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespace/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:18Z",
                "name": "prometheus-k8s-machine-api-operator",
                "namespace": "openshift-machine-api",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2347",
                "uid": "a0a01358-02bf-4e9d-90e5-9e6baab5f23f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespace/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:56Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-machine-config-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1699",
                "uid": "08567da6-b0f1-4d87-acf6-460742b6be98"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:17Z",
                "name": "7513205fd8b02c7263a18bdf27edd13e569f86266120fde7b8430dfd8dcaa46",
                "namespace": "openshift-marketplace",
                "ownerReferences": [
                    {
                        "apiVersion": "v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ConfigMap",
                        "name": "7513205fd8b02c7263a18bdf27edd13e569f86266120fde7b8430dfd8dcaa46",
                        "uid": "135a2649-6129-4bda-8bf6-fb51895432e2"
                    }
                ],
                "resourceVersion": "40417",
                "uid": "6ad7d84b-3441-4ff5-8c9b-da0177b3399e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "7513205fd8b02c7263a18bdf27edd13e569f86266120fde7b8430dfd8dcaa46"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:35Z",
                "name": "marketplace-operator",
                "namespace": "openshift-marketplace",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1194",
                "uid": "32896495-56b6-4526-81b7-7bb1f57b5bc4"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "delete",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "delete",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "delete",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:04Z",
                "name": "openshift-marketplace-metrics",
                "namespace": "openshift-marketplace",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "8662",
                "uid": "3552a779-5429-45ba-8e12-632d67676e13"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:01Z",
                "name": "monitoring-alertmanager-edit",
                "namespace": "openshift-monitoring",
                "resourceVersion": "8457",
                "uid": "1e06b6a6-4c31-44ea-afdc-f133f50e6098"
            },
            "rules": [
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resourceNames": [
                        "non-existant"
                    ],
                    "resources": [
                        "alertmanagers"
                    ],
                    "verbs": [
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "namespace": "openshift-monitoring",
                "resourceVersion": "20023",
                "uid": "77cfa0f9-e77e-40e9-9cbc-a8c97f86da92"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s-config",
                "namespace": "openshift-monitoring",
                "resourceVersion": "20015",
                "uid": "c882557c-f9aa-4e48-8281-918975c58da5"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-multus",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2676",
                "uid": "fcde8947-f510-475a-a715-681b6a4837d3"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "whereabouts-cni",
                "namespace": "openshift-multus",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2613",
                "uid": "716b3deb-eba5-46b3-adea-4322789370af"
            },
            "rules": [
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:05Z",
                "name": "network-diagnostics",
                "namespace": "openshift-network-diagnostics",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2830",
                "uid": "3f9570ae-32af-43e5-8e40-e640cc127317"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:05Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-network-diagnostics",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2906",
                "uid": "78bbda39-e70c-48ca-abe8-026fc3504168"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:35Z",
                "name": "system:node-config-reader",
                "namespace": "openshift-node",
                "resourceVersion": "9729",
                "uid": "e9bc046d-6eab-4b14-a694-e383c78cbf5c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "exclude.release.openshift.io/internal-openshift-hosted": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:47:27Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-oauth-apiserver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "7266",
                "uid": "aa86fc31-ebef-46a2-a58a-24fef5d5ade7"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:57Z",
                "name": "collect-profiles",
                "namespace": "openshift-operator-lifecycle-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1734",
                "uid": "dd38a2ef-5415-4a97-8523-176324a6a47c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "create",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:36Z",
                "name": "operator-lifecycle-manager-metrics",
                "namespace": "openshift-operator-lifecycle-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1222",
                "uid": "0d838743-794b-4f1f-9b72-25cc75cb7abf"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "name": "packageserver",
                "namespace": "openshift-operator-lifecycle-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v2",
                        "blockOwnerDeletion": false,
                        "controller": true,
                        "kind": "OperatorCondition",
                        "name": "packageserver",
                        "uid": "c94bb6b0-34c1-4ff9-ba12-9e57567d04f5"
                    }
                ],
                "resourceVersion": "6232",
                "uid": "74ae6d41-4416-4212-9699-9e269b15fbd7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resourceNames": [
                        "packageserver"
                    ],
                    "resources": [
                        "operatorconditions"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "name": "packageserver-service-cert",
                "namespace": "openshift-operator-lifecycle-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "operators.coreos.com/v1alpha1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "ClusterServiceVersion",
                        "name": "packageserver",
                        "uid": "e2532c78-e6b1-4686-9a95-e570ef1130fe"
                    }
                ],
                "resourceVersion": "6283",
                "uid": "67158473-2aa6-4aea-992e-0a705e500d00"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "packageserver-service-cert"
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "openshift-ovn-kubernetes-sbdb",
                "namespace": "openshift-ovn-kubernetes",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2732",
                "uid": "d19982ab-a599-4969-9963-3205a2a07506"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:05Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-ovn-kubernetes",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2754",
                "uid": "218940a6-f506-4550-9ca2-eb904935e8f1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:32Z",
                "name": "prometheus-k8s",
                "namespace": "openshift-service-ca-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1094",
                "uid": "1441ee84-20fe-4be7-8323-23defd4f7748"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:controller:service-ca",
                "namespace": "openshift-service-ca",
                "resourceVersion": "4601",
                "uid": "5301a760-d0af-4564-8725-a1f8b15171f3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "restricted"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "replicasets",
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:17Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "namespace": "openshift-user-workload-monitoring",
                "resourceVersion": "20026",
                "uid": "52626584-6999-482c-bd79-769899309bcf"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:01Z",
                "name": "user-workload-monitoring-config-edit",
                "namespace": "openshift-user-workload-monitoring",
                "resourceVersion": "8452",
                "uid": "af5ef518-953d-461c-8704-75560a82526c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "user-workload-monitoring-config"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "Role",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:35Z",
                "name": "shared-resource-viewer",
                "namespace": "openshift",
                "resourceVersion": "9717",
                "uid": "ab942f5d-3b13-4135-b35c-9a6f46466325"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF
