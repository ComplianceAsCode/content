#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/deployments"

deployment_apipath="/apis/apps/v1/deployments?limit=500"

# This file assumes that we have 6 deployments, and
# for all the deployment either requests or limits were not defined.
cat <<EOF > "$kube_apipath$deployment_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:58Z",
                "generation": 1,
                "name": "deployment-with-resource-only-limits-cpu",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37315",
                "uid": "debdd0ff-889a-4771-872b-efb0ee9b65de"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "limits": {
                                        "cpu": "500m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "ReplicaSet \"deployment-with-resource-only-limits-cpu-89974b47d\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:58Z",
                "generation": 1,
                "name": "deployment-with-resource-only-limits-memory",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37300",
                "uid": "a66ab700-10d1-46ce-89f3-9178e3cfa2f0"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "limits": {
                                        "memory": "128Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "ReplicaSet \"deployment-with-resource-only-limits-memory-7df6bc97c5\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:57Z",
                "generation": 1,
                "name": "deployment-with-resource-only-requests-cpu",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37273",
                "uid": "f0644762-8b6c-4bbc-b324-6e8724219826"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "250m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "ReplicaSet \"deployment-with-resource-only-requests-cpu-6d58f6464\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:57Z",
                "generation": 1,
                "name": "deployment-with-resource-only-requests-memory",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37258",
                "uid": "0bda87e6-f052-49ae-a3e4-61ae246c7300"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "memory": "64Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "ReplicaSet \"deployment-with-resource-only-requests-memory-9c49df96b\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:57Z",
                "generation": 1,
                "name": "deployment-without-resource-limits",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37246",
                "uid": "e0132dfd-d709-4e5a-9be2-43b031a34e49"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "250m",
                                        "memory": "64Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:57Z",
                        "lastUpdateTime": "2021-12-30T08:48:57Z",
                        "message": "ReplicaSet \"deployment-without-resource-limits-f9b649dcb\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2021-12-30T08:48:58Z",
                "generation": 1,
                "name": "deployment-without-resource-requests",
                "namespace": "cmp-resource-test",
                "resourceVersion": "37288",
                "uid": "8bd83687-8246-4ace-a76a-b61874b2395c"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": "25%"
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nginx"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nginx",
                                "imagePullPolicy": "Always",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "limits": {
                                        "cpu": "500m",
                                        "memory": "128Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                }
            },
            "status": {
                "conditions": [
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:48:58Z",
                        "lastUpdateTime": "2021-12-30T08:48:58Z",
                        "message": "ReplicaSet \"deployment-without-resource-requests-5cfbc579c\" is progressing.",
                        "reason": "ReplicaSetUpdated",
                        "status": "True",
                        "type": "Progressing"
                    }
                ],
                "observedGeneration": 1,
                "replicas": 1,
                "unavailableReplicas": 1,
                "updatedReplicas": 1
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

jq_filter='[ .items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select( .spec.template.spec.containers[].resources.requests.cpu == null  or  .spec.template.spec.containers[].resources.requests.memory == null or .spec.template.spec.containers[].resources.limits.cpu == null  or  .spec.template.spec.containers[].resources.limits.memory == null )  | .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"