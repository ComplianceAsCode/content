#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/statefulsets"

statefulset_apipath="/apis/apps/v1/statefulsets?limit=500"

# This file assumes that we have 1 statefulsets & dont have the resource requests and limits
cat <<EOF > "$kube_apipath$statefulset_apipath"
{
    "apiVersion": "v1",
    "items": [
{
    "apiVersion": "apps/v1",
    "kind": "StatefulSet",
    "metadata": {
        "creationTimestamp": "2021-12-30T09:26:47Z",
        "generation": 1,
        "labels": {
            "app": "nginx"
        },
        "name": "statefulset-without-resource",
        "namespace": "cmp-resource-limit-test",
        "resourceVersion": "50061",
        "uid": "db840d4a-776b-421a-8fdd-572da583beac"
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
                        "resources": {},
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
        "currentRevision": "statefulset-without-resource-b46f789c4",
        "observedGeneration": 1,
        "replicas": 1,
        "updateRevision": "statefulset-without-resource-b46f789c4",
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