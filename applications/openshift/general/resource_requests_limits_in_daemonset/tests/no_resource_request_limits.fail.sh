#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/daemonsets"

daemonsets_apipath="/apis/apps/v1/daemonsets?limit=500"

# This file assumes that we have 1 daemonsets & dont have the resource requests and limits
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
                "creationTimestamp": "2021-12-30T10:05:11Z",
                "generation": 1,
                "labels": {
                    "k8s-app": "fluentd-logging"
                },
                "name": "fluentd-without-resource",
                "namespace": "cmp-resource-limit-test",
                "resourceVersion": "69807",
                "uid": "18fd39c9-f493-4c02-a8fd-2f5fc9dc90f4"
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
                                "resources": {},
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