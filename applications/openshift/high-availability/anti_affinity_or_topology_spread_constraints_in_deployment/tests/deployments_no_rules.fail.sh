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
            }
        },
        {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {
                "annotations": {
                    "deployment.kubernetes.io/revision": "161"
                },
                "creationTimestamp": "2022-04-19T12:58:24Z",
                "generation": 163,
                "labels": {
                    "app.kubernetes.io/component": "repo-server",
                    "app.kubernetes.io/managed-by": "argocd",
                    "app.kubernetes.io/name": "argocd-repo-server",
                    "app.kubernetes.io/part-of": "argocd"
                },
                "name": "argocd-repo-server",
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
                "resourceVersion": "1357676885",
                "uid": "f099a55f-a7f9-48d1-8809-828868f83bcf"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 3,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/name": "argocd-repo-server"
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
                            "app.kubernetes.io/name": "argocd-repo-server",
                            "image.upgraded": "11082023-014723-UTC"
                        }
                    },
                    "spec": {
                        "automountServiceAccountToken": false,
                        "containers": [
                            {
                                "command": [
                                    "uid_entrypoint.sh",
                                    "argocd-repo-server",
                                    "--redis",
                                    "argocd-redis.argocd.svc.cluster.local:6379",
                                    "--loglevel",
                                    "info",
                                    "--logformat",
                                    "text"
                                ],
                                "image": "registry.redhat.io/openshift-gitops-1/argocd-rhel8@sha256:f77594bc053be144b33ff9603ee9675c7e82946ec0dbfb04d8f942c8d73155da",
                                "imagePullPolicy": "Always",
                                "livenessProbe": {
                                    "failureThreshold": 3,
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "tcpSocket": {
                                        "port": 8081
                                    },
                                    "timeoutSeconds": 1
                                },
                                "name": "argocd-repo-server",
                                "ports": [
                                    {
                                        "containerPort": 8081,
                                        "name": "server",
                                        "protocol": "TCP"
                                    },
                                    {
                                        "containerPort": 8084,
                                        "name": "metrics",
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 3,
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "tcpSocket": {
                                        "port": 8081
                                    },
                                    "timeoutSeconds": 1
                                },
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/app/config/ssh",
                                        "name": "ssh-known-hosts"
                                    },
                                    {
                                        "mountPath": "/app/config/tls",
                                        "name": "tls-certs"
                                    },
                                    {
                                        "mountPath": "/app/config/gpg/source",
                                        "name": "gpg-keys"
                                    },
                                    {
                                        "mountPath": "/app/config/gpg/keys",
                                        "name": "gpg-keyring"
                                    },
                                    {
                                        "mountPath": "/tmp",
                                        "name": "tmp"
                                    },
                                    {
                                        "mountPath": "/app/config/reposerver/tls",
                                        "name": "argocd-repo-server-tls"
                                    },
                                    {
                                        "mountPath": "/app/config/reposerver/tls/redis",
                                        "name": "argocd-operator-redis-tls"
                                    },
                                    {
                                        "mountPath": "/home/argocd/cmp-server/plugins",
                                        "name": "plugins"
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
                                    "/var/run/argocd/argocd-cmp-server"
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
                                        "mountPath": "/var/run/argocd",
                                        "name": "var-files"
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
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "argocd-ssh-known-hosts-cm"
                                },
                                "name": "ssh-known-hosts"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "argocd-tls-certs-cm"
                                },
                                "name": "tls-certs"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "argocd-gpg-keys-cm"
                                },
                                "name": "gpg-keys"
                            },
                            {
                                "emptyDir": {},
                                "name": "gpg-keyring"
                            },
                            {
                                "emptyDir": {},
                                "name": "tmp"
                            },
                            {
                                "name": "argocd-repo-server-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "optional": true,
                                    "secretName": "argocd-repo-server-tls"
                                }
                            },
                            {
                                "name": "argocd-operator-redis-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "optional": true,
                                    "secretName": "argocd-operator-redis-tls"
                                }
                            },
                            {
                                "emptyDir": {},
                                "name": "var-files"
                            },
                            {
                                "emptyDir": {},
                                "name": "plugins"
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
                    "deployment.kubernetes.io/revision": "143"
                },
                "creationTimestamp": "2022-04-19T12:58:24Z",
                "generation": 143,
                "labels": {
                    "app.kubernetes.io/component": "server",
                    "app.kubernetes.io/managed-by": "argocd",
                    "app.kubernetes.io/name": "argocd-server",
                    "app.kubernetes.io/part-of": "argocd"
                },
                "name": "argocd-server",
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
                "resourceVersion": "1357676941",
                "uid": "4572963f-3e9d-4260-a8d7-bda9e557e093"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 3,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/name": "argocd-server"
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
                            "app.kubernetes.io/name": "argocd-server",
                            "image.upgraded": "11082023-014723-UTC"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "command": [
                                    "argocd-server",
                                    "--insecure",
                                    "--staticassets",
                                    "/shared/app",
                                    "--dex-server",
                                    "https://argocd-dex-server.argocd.svc.cluster.local:5556",
                                    "--repo-server",
                                    "argocd-repo-server.argocd.svc.cluster.local:8081",
                                    "--redis",
                                    "argocd-redis.argocd.svc.cluster.local:6379",
                                    "--loglevel",
                                    "info",
                                    "--logformat",
                                    "text"
                                ],
                                "image": "registry.redhat.io/openshift-gitops-1/argocd-rhel8@sha256:f77594bc053be144b33ff9603ee9675c7e82946ec0dbfb04d8f942c8d73155da",
                                "imagePullPolicy": "Always",
                                "livenessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": 8080,
                                        "scheme": "HTTP"
                                    },
                                    "initialDelaySeconds": 3,
                                    "periodSeconds": 30,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "argocd-server",
                                "ports": [
                                    {
                                        "containerPort": 8080,
                                        "protocol": "TCP"
                                    },
                                    {
                                        "containerPort": 8083,
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": 8080,
                                        "scheme": "HTTP"
                                    },
                                    "initialDelaySeconds": 3,
                                    "periodSeconds": 30,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/app/config/ssh",
                                        "name": "ssh-known-hosts"
                                    },
                                    {
                                        "mountPath": "/app/config/tls",
                                        "name": "tls-certs"
                                    },
                                    {
                                        "mountPath": "/app/config/server/tls",
                                        "name": "argocd-repo-server-tls"
                                    },
                                    {
                                        "mountPath": "/app/config/server/tls/redis",
                                        "name": "argocd-operator-redis-tls"
                                    }
                                ]
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
                        "serviceAccount": "argocd-argocd-server",
                        "serviceAccountName": "argocd-argocd-server",
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
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "argocd-ssh-known-hosts-cm"
                                },
                                "name": "ssh-known-hosts"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "argocd-tls-certs-cm"
                                },
                                "name": "tls-certs"
                            },
                            {
                                "name": "argocd-repo-server-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "optional": true,
                                    "secretName": "argocd-repo-server-tls"
                                }
                            },
                            {
                                "name": "argocd-operator-redis-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "optional": true,
                                    "secretName": "argocd-operator-redis-tls"
                                }
                            }
                        ]
                    }
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


jq_filter='[ .items[] | select(.metadata.name | test("{{.var_deployments_without_high_availability}}"; "") | not) | select (.spec.replicas == 0 or .spec.replicas == 1 | not) | select(.spec.template.spec.affinity.podAntiAffinity == null and .spec.template.spec.topologySpreadConstraints == null) | .metadata.namespace + "/" + .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"
