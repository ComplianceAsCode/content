#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/statefulsets"

statefulset_apipath="/apis/apps/v1/statefulsets?limit=500"

# This file assumes that we have 6 statefulsets, and
# for all the statefulsets either requests or limits were not defined.
cat <<EOF > "$kube_apipath$statefulset_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:31Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-with-resource-limits-cpu",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47739",
                "uid": "0eadfce8-1e47-4bd8-9509-549e0305cf63"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "limits": {
                                        "cpu": "500m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-with-resource-limits-cpu-7f9d7b6b54",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-with-resource-limits-cpu-7f9d7b6b54",
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:31Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-with-resource-limits-memory",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47724",
                "uid": "01855501-31b8-4780-9974-2c6d007cc875"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "limits": {
                                        "memory": "128Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-with-resource-limits-memory-77cb666474",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-with-resource-limits-memory-77cb666474",
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:30Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-with-resource-request-memory",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47703",
                "uid": "4f51487e-57ef-427c-b329-df2e1f119fe7"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "memory": "64Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-with-resource-request-memory-5b7f4469d5",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-with-resource-request-memory-5b7f4469d5",
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:31Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-with-resource-requests-cpu",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47715",
                "uid": "33cdfcea-163d-4406-bbab-545e0eac0656"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "250m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-with-resource-requests-cpu-7dc58fddd4",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-with-resource-requests-cpu-7dc58fddd4",
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:32Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-without-resource-limits",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47760",
                "uid": "b80561dc-1458-4793-871c-98554b50c3a3"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
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
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-without-resource-limits-d5c8547df",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-without-resource-limits-d5c8547df",
                "updatedReplicas": 1
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2021-12-30T09:20:31Z",
                "generation": 1,
                "labels": {
                    "app": "nginx"
                },
                "name": "statefulset-without-resource-request",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "47748",
                "uid": "4edd04fc-ea5d-4c81-830e-9090d4573a54"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 14,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nginx"
                    }
                },
                "serviceName": "nginx",
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
                                "image": "k8s.gcr.io/nginx-slim:0.8",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "nginx",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "name": "web",
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
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/usr/share/nginx/html",
                                        "name": "www"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "www"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "1Gi"
                                }
                            },
                            "storageClassName": "thin-disk",
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
            },
            "status": {
                "collisionCount": 0,
                "currentReplicas": 1,
                "currentRevision": "statefulset-without-resource-request-687c59b58",
                "observedGeneration": 1,
                "replicas": 1,
                "updateRevision": "statefulset-without-resource-request-687c59b58",
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
filteredpath="$kube_apipath$statefulset_apipath#$(echo -n "$statefulset_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$statefulset_apipath" > "$filteredpath"