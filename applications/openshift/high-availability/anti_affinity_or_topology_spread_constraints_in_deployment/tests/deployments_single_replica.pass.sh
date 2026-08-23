#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/deployments"

deployment_apipath="/apis/apps/v1/deployments?limit=500"

cat <<EOF > "$kube_apipath$deployment_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "198"
                },
                "creationTimestamp": "2022-08-19T13:10:14Z",
                "generation": 216,
                "labels": {
                    "app.kubernetes.io/component": "dex-server",
                    "app.kubernetes.io/managed-by": "argocd",
                    "app.kubernetes.io/name": "argocd-dex-server",
                    "app.kubernetes.io/part-of": "argocd"
                },
                "name": "argocd-dex-server",
                "namespace": "argocd",
                "ownerReferences": [
                    {
                        "apiVersion": "argoproj.io/v1alpha1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ArgoCD",
                        "name": "argocd",
                        "uid": "366e4fb4-f3b1-4f1e-b319-a886aaae928a"
                    }
                ],
                "resourceVersion": "1303859027",
                "uid": "5a0e160e-371d-4412-a697-bd07453e71c1"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/name": "argocd-dex-server"
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
                            "app.kubernetes.io/name": "argocd-dex-server",
                            "dex.config.changed": "10242023-134623-UTC",
                            "image.upgraded": "11082023-014723-UTC"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "command": [
                                    "/shared/argocd-dex",
                                    "rundex"
                                ],
                                "image": "registry.redhat.io/openshift-gitops-1/dex-rhel8@sha256:8cc59901689858e06f5c2942f8c975449c17454fa8364da6153d9b5a3538a985",
                                "imagePullPolicy": "Always",
                                "livenessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz/live",
                                        "port": 5558,
                                        "scheme": "HTTP"
                                    },
                                    "initialDelaySeconds": 60,
                                    "periodSeconds": 30,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "dex",
                                "ports": [
                                    {
                                        "containerPort": 5556,
                                        "name": "http",
                                        "protocol": "TCP"
                                    },
                                    {
                                        "containerPort": 5557,
                                        "name": "grpc",
                                        "protocol": "TCP"
                                    },
                                    {
                                        "containerPort": 5558,
                                        "name": "metrics",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {},
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    },
                                    "runAsNonRoot": true
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/shared",
                                        "name": "static-files"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "initContainers": [
                            {
                                "command": [
                                    "cp",
                                    "-n",
                                    "/usr/local/bin/argocd",
                                    "/shared/argocd-dex"
                                ],
                                "image": "registry.redhat.io/openshift-gitops-1/argocd-rhel8@sha256:f77594bc053be144b33ff9603ee9675c7e82946ec0dbfb04d8f942c8d73155da",
                                "imagePullPolicy": "Always",
                                "name": "copyutil",
                                "resources": {},
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    },
                                    "runAsNonRoot": true
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/shared",
                                        "name": "static-files"
                                    }
                                ]
                            }
                        ],
                        "nodeSelector": {
                            "kubernetes.io/os": "linux",
                            "node-role.kubernetes.io/infra": ""
                        },
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "argocd-argocd-dex-server",
                        "serviceAccountName": "argocd-argocd-dex-server",
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/infra",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "emptyDir": {},
                                "name": "static-files"
                            }
                        ]
                    }
                }
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "27"
                },
                "creationTimestamp": "2022-04-19T12:58:24Z",
                "generation": 29,
                "labels": {
                    "app.kubernetes.io/component": "redis",
                    "app.kubernetes.io/managed-by": "argocd",
                    "app.kubernetes.io/name": "argocd-redis",
                    "app.kubernetes.io/part-of": "argocd"
                },
                "name": "argocd-redis",
                "namespace": "argocd",
                "ownerReferences": [
                    {
                        "apiVersion": "argoproj.io/v1alpha1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "ArgoCD",
                        "name": "argocd",
                        "uid": "366e4fb4-f3b1-4f1e-b319-a886aaae928a"
                    }
                ],
                "resourceVersion": "1357676855",
                "uid": "269ad8b0-2de5-4302-94b1-66bfe9460483"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/name": "argocd-redis"
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
                            "app.kubernetes.io/name": "argocd-redis",
                            "image.upgraded": "11072023-102823-UTC"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "args": [
                                    "redis-server",
                                    "--protected-mode",
                                    "no",
                                    "--save",
                                    "",
                                    "--appendonly",
                                    "no"
                                ],
                                "image": "registry.redhat.io/rhel8/redis-6@sha256:edbd40185ed8c20ee61ebdf9f2e1e1d7594598fceff963b4dee3201472d6deda",
                                "imagePullPolicy": "Always",
                                "name": "redis",
                                "ports": [
                                    {
                                        "containerPort": 6379,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "kubernetes.io/os": "linux",
                            "node-role.kubernetes.io/infra": ""
                        },
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/infra",
                                "operator": "Exists"
                            }
                        ]
                    }
                }
            },
            "status": {
                "availableReplicas": 1,
                "conditions": [
                    {
                        "lastTransitionTime": "2022-04-19T12:58:24Z",
                        "lastUpdateTime": "2023-11-07T10:28:41Z",
                        "message": "ReplicaSet \"argocd-redis-6bfd7df9fd\" has successfully progressed.",
                        "reason": "NewReplicaSetAvailable",
                        "status": "True",
                        "type": "Progressing"
                    },
                    {
                        "lastTransitionTime": "2024-07-11T13:58:40Z",
                        "lastUpdateTime": "2024-07-11T13:58:40Z",
                        "message": "Deployment has minimum availability.",
                        "reason": "MinimumReplicasAvailable",
                        "status": "True",
                        "type": "Available"
                    }
                ],
                "observedGeneration": 29,
                "readyReplicas": 1,
                "replicas": 1,
                "updatedReplicas": 1
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": ""
    }
}
EOF


jq_filter='[ .items[] | select(.metadata.name | test("{{.var_deployments_without_high_availability}}"; "") | not) | select (.spec.replicas == 0 or .spec.replicas == 1 | not) | select(.spec.template.spec.affinity.podAntiAffinity == null and .spec.template.spec.topologySpreadConstraints == null) | .metadata.namespace + "/" + .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"
