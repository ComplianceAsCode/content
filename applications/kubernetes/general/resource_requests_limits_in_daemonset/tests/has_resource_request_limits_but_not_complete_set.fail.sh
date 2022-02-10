#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/daemonsets"

daemonsets_apipath="/apis/apps/v1/daemonsets?limit=500"

# This file assumes that we have 6 daemonsets, and
# for all the Daemonset either requests or limits were not defined.
cat <<EOF > "$kube_apipath$daemonsets_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T09:59:03Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-with-resource-limits-cpu",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "65764",
                "uid": "6d6569bd-a0f8-49c9-9fdd-7be82edbf444"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "limits": {
                                        "cpu": "100m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T09:59:03Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-with-resource-limits-memory",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "65760",
                "uid": "3173bd96-b186-4a94-9f37-9f5942c108f9"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "limits": {
                                        "memory": "200Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T09:59:02Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-with-resource-request-cpu",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "65768",
                "uid": "09259b00-a98f-4964-98ab-39cb6d3dc237"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "requests": {
                                        "cpu": "100m"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T09:59:02Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-with-resource-request-memory",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "65770",
                "uid": "5e341b2d-3ec7-4900-978c-fdf3156f5753"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "requests": {
                                        "memory": "200Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T10:00:50Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-without-resource-limits",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "66626",
                "uid": "4c68d210-fed0-4cde-a2f1-c65b72a7d378"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "requests": {
                                        "cpu": "100m",
                                        "memory": "200Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "DaemonSet",
            "metadata": {
                "annotations": {
                    "deprecated.daemonset.template.generation": "1"
                },
                "creationTimestamp": "2021-12-30T10:00:50Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-without-resource-request",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "66614",
                "uid": "d7bd5e6b-36a5-481c-bb7b-234efea1ad21"
            },
            "spec": {
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "name": "fluentd-elasticsearch"
                    }
                },
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "name": "fluentd-elasticsearch"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "quay.io/fluentd_elasticsearch/fluentd:v2.5.2",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "fluentd-elasticsearch",
                                "resources": {
                                    "limits": {
                                        "cpu": "100m",
                                        "memory": "200Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/log",
                                        "name": "varlog"
                                    },
                                    {
                                        "mountPath": "/var/lib/docker/containers",
                                        "name": "varlibdockercontainers",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/master",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "hostPath": {
                                    "path": "/var/log",
                                    "type": ""
                                },
                                "name": "varlog"
                            },
                            {
                                "hostPath": {
                                    "path": "/var/lib/docker/containers",
                                    "type": ""
                                },
                                "name": "varlibdockercontainers"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "maxSurge": 0,
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                }
            },
            "status": {
                "currentNumberScheduled": 6,
                "desiredNumberScheduled": 6,
                "numberAvailable": 6,
                "numberMisscheduled": 0,
                "numberReady": 6,
                "observedGeneration": 1,
                "updatedNumberScheduled": 6
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
filteredpath="$kube_apipath$daemonsets_apipath#$(echo -n "$daemonsets_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$daemonsets_apipath" > "$filteredpath"