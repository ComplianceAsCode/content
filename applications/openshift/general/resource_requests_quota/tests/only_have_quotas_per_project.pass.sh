#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/api/v1"

quota_apipath="/api/v1/resourcequotas"

# This file assumes three namespaces ns-one,ns-two,ns-three, all three have resource quota set

cat <<EOF > "$kube_apipath$quota_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "ResourceQuota",
            "metadata": {
                "creationTimestamp": "2021-11-14T21:58:53Z",
                "name": "example-1",
                "namespace": "ns-one",
                "resourceVersion": "107220",
                "uid": "73473fd6-d6f5-4691-ac5d-17f633eb853c"
            },
            "spec": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                }
            },
            "status": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                },
                "used": {
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0",
                    "requests.cpu": "0",
                    "requests.memory": "0"
                }
            }
        },
        {
            "apiVersion": "v1",
            "kind": "ResourceQuota",
            "metadata": {
                "creationTimestamp": "2021-11-14T22:12:17Z",
                "name": "example-3",
                "namespace": "ns-three",
                "resourceVersion": "111083",
                "uid": "a2047dd3-14a1-4349-a9e0-2dce70acb90b"
            },
            "spec": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                }
            },
            "status": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                },
                "used": {
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0",
                    "requests.cpu": "0",
                    "requests.memory": "0"
                }
            }
        },
        {
            "apiVersion": "v1",
            "kind": "ResourceQuota",
            "metadata": {
                "creationTimestamp": "2021-11-14T21:59:30Z",
                "name": "example-2",
                "namespace": "ns-two",
                "resourceVersion": "107477",
                "uid": "32ddee16-0b47-453e-b2f5-8a8112db1cb4"
            },
            "spec": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                }
            },
            "status": {
                "hard": {
                    "limits.cpu": "2",
                    "limits.memory": "2Gi",
                    "pods": "4",
                    "requests.cpu": "1",
                    "requests.memory": "1Gi"
                },
                "used": {
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0",
                    "requests.cpu": "0",
                    "requests.memory": "0"
                }
            }
        },
        {
            "apiVersion": "v1",
            "kind": "ResourceQuota",
            "metadata": {
                "creationTimestamp": "2021-11-14T16:41:40Z",
                "name": "host-network-namespace-quotas",
                "namespace": "openshift-host-network",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "24e6d8cb-e139-4515-ab61-e1d107eb6f6e"
                    }
                ],
                "resourceVersion": "2935",
                "uid": "877517c5-8992-4af6-b884-4197b952b007"
            },
            "spec": {
                "hard": {
                    "count/daemonsets.apps": "0",
                    "count/deployments.apps": "0",
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0"
                }
            },
            "status": {
                "hard": {
                    "count/daemonsets.apps": "0",
                    "count/deployments.apps": "0",
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0"
                },
                "used": {
                    "count/daemonsets.apps": "0",
                    "count/deployments.apps": "0",
                    "limits.cpu": "0",
                    "limits.memory": "0",
                    "pods": "0"
                }
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

quota_jq_filter='[.items[] | select((.metadata.namespace | startswith("openshift") | not) and (.metadata.namespace | startswith("kube-") | not) and .metadata.namespace != "default") | .metadata.namespace] | unique'

# Get file path. This will actually be read by the scan
quota_filteredpath="$kube_apipath$quota_apipath#$(echo -n "$quota_apipath$quota_jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$quota_jq_filter" "$kube_apipath$quota_apipath" > "$quota_filteredpath"

ns_apipath="/api/v1/namespaces"

cat <<EOF > "$kube_apipath$ns_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {
                "annotations": {
                    "openshift.io/sa.scc.mcs": "s0:c6,c5",
                    "openshift.io/sa.scc.supplemental-groups": "1000040000/10000",
                    "openshift.io/sa.scc.uid-range": "1000040000/10000"
                },
                "creationTimestamp": "2021-11-14T16:38:56Z",
                "labels": {
                    "kubernetes.io/metadata.name": "default"
                },
                "name": "default",
                "resourceVersion": "531",
                "uid": "6cf5e941-0ea4-4204-8798-f1e0343dfa2d"
            },
            "spec": {
                "finalizers": [
                    "kubernetes"
                ]
            },
            "status": {
                "phase": "Active"
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "",
                    "openshift.io/display-name": "",
                    "openshift.io/requester": "wenshen@redhat.com",
                    "openshift.io/sa.scc.mcs": "s0:c26,c0",
                    "openshift.io/sa.scc.supplemental-groups": "1000650000/10000",
                    "openshift.io/sa.scc.uid-range": "1000650000/10000"
                },
                "creationTimestamp": "2021-11-14T21:46:29Z",
                "labels": {
                    "kubernetes.io/metadata.name": "ns-one"
                },
                "name": "ns-one",
                "resourceVersion": "103815",
                "uid": "3640228a-9055-45d7-922a-e919a86e5d63"
            },
            "spec": {
                "finalizers": [
                    "kubernetes"
                ]
            },
            "status": {
                "phase": "Active"
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "",
                    "openshift.io/display-name": "",
                    "openshift.io/requester": "wenshen@redhat.com",
                    "openshift.io/sa.scc.mcs": "s0:c26,c15",
                    "openshift.io/sa.scc.supplemental-groups": "1000680000/10000",
                    "openshift.io/sa.scc.uid-range": "1000680000/10000"
                },
                "creationTimestamp": "2021-11-14T21:59:25Z",
                "labels": {
                    "kubernetes.io/metadata.name": "ns-three"
                },
                "name": "ns-three",
                "resourceVersion": "107422",
                "uid": "cc258750-6f90-4b7b-9c0f-201a1d332406"
            },
            "spec": {
                "finalizers": [
                    "kubernetes"
                ]
            },
            "status": {
                "phase": "Active"
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "",
                    "openshift.io/display-name": "",
                    "openshift.io/requester": "wenshen@redhat.com",
                    "openshift.io/sa.scc.mcs": "s0:c26,c5",
                    "openshift.io/sa.scc.supplemental-groups": "1000660000/10000",
                    "openshift.io/sa.scc.uid-range": "1000660000/10000"
                },
                "creationTimestamp": "2021-11-14T21:59:17Z",
                "labels": {
                    "kubernetes.io/metadata.name": "ns-two"
                },
                "name": "ns-two",
                "resourceVersion": "107337",
                "uid": "2a24071a-daf9-4505-9267-4720c82f2752"
            },
            "spec": {
                "finalizers": [
                    "kubernetes"
                ]
            },
            "status": {
                "phase": "Active"
            }
        },
        {
            "apiVersion": "v1",
            "kind": "Namespace",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "openshift.io/node-selector": "",
                    "openshift.io/sa.scc.mcs": "s0:c20,c10",
                    "openshift.io/sa.scc.supplemental-groups": "1000400000/10000",
                    "openshift.io/sa.scc.uid-range": "1000400000/10000",
                    "workload.openshift.io/allowed": "management"
                },
                "creationTimestamp": "2021-11-14T16:39:39Z",
                "labels": {
                    "kubernetes.io/metadata.name": "openshift-vsphere-infra",
                    "name": "openshift-vsphere-infra"
                },
                "name": "openshift-vsphere-infra",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "23ac4f4e-1f3b-446e-bf5d-d90949db12e2"
                    }
                ],
                "resourceVersion": "1247",
                "uid": "d0718750-f09f-42de-9327-f97e8c8a61cb"
            },
            "spec": {
                "finalizers": [
                    "kubernetes"
                ]
            },
            "status": {
                "phase": "Active"
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

ns_jq_filter='[.items[] | select((.metadata.name | startswith("openshift") | not) and (.metadata.name | startswith("kube-") | not) and .metadata.name != "default")]'

# Get file path. This will actually be read by the scan
ns_filteredpath="$kube_apipath$ns_apipath#$(echo -n "$ns_apipath$ns_jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$ns_jq_filter" "$kube_apipath$ns_apipath" > "$ns_filteredpath"