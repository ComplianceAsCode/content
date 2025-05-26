#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/statefulsets"

statefulset_apipath="/apis/apps/v1/statefulsets?limit=500"

# This file assumes that we dont have any statefulsets.
cat <<EOF > "$kube_apipath$statefulset_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2024-07-15T10:14:13Z",
                "generation": 1,
                "labels": {
                    "app": "webserver"
                },
                "name": "webserver",
                "namespace": "aiate",
                "resourceVersion": "1363639972",
                "uid": "3b008246-7297-4492-a093-d30102d94c9c"
            },
            "spec": {
                "podManagementPolicy": "OrderedReady",
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "webserver"
                    }
                },
                "serviceName": "",
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app": "webserver"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "command": [
                                    "nginx",
                                    "-g",
                                    "daemon off;"
                                ],
                                "image": "registry.access.redhat.com/ubi9/nginx-120:1-148.1719561315",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "webserver",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "topologySpreadConstraints": [
                            {
                                "labelSelector": {
                                    "matchLabels": {
                                        "app": "webserver"
                                    }
                                },
                                "maxSkew": 1,
                                "topologyKey": "topology.kubernetes.io/zone",
                                "whenUnsatisfiable": "DoNotSchedule"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "rollingUpdate": {
                        "partition": 0
                    },
                    "type": "RollingUpdate"
                }
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
EOF


jq_filter='[ .items[] | select(.metadata.name | test("{{.var_statefulsets_without_high_availability}}"; "") | not) | select (.spec.replicas == 0 or .spec.replicas == 1 | not) | select(.spec.template.spec.affinity.podAntiAffinity == null and .spec.template.spec.topologySpreadConstraints == null) | .metadata.namespace + "/" + .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$statefulset_apipath#$(echo -n "$statefulset_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$statefulset_apipath" > "$filteredpath"
