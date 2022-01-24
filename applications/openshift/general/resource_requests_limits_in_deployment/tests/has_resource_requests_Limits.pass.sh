#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/deployments"

deployment_apipath="/apis/apps/v1/deployments?limit=500"

# This file assumes that we have 1 deployments & have the resource requests and limits
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
                "creationTimestamp": "2021-12-30T08:30:52Z",
                "generation": 1,
                "name": "deployment-with-resource",
                "namespace": "cmp-resource-test",
                "resourceVersion": "34637",
                "uid": "55e83898-3925-475e-ad96-b1fb098f6dfd"
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
                                    },
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
                        "lastTransitionTime": "2021-12-30T08:30:52Z",
                        "lastUpdateTime": "2021-12-30T08:30:52Z",
                        "message": "Deployment does not have minimum availability.",
                        "reason": "MinimumReplicasUnavailable",
                        "status": "False",
                        "type": "Available"
                    },
                    {
                        "lastTransitionTime": "2021-12-30T08:40:53Z",
                        "lastUpdateTime": "2021-12-30T08:40:53Z",
                        "message": "ReplicaSet \"deployment-with-resource-7b5977cd56\" has timed out progressing.",
                        "reason": "ProgressDeadlineExceeded",
                        "status": "False",
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