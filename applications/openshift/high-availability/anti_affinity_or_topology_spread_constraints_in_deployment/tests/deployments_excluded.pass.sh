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
jq_filter_with_var='[ .items[] | select(.metadata.name | test("^argocd-server$"; "") | not) | select (.spec.replicas == 0 or .spec.replicas == 1 | not) | select(.spec.template.spec.affinity.podAntiAffinity == null and .spec.template.spec.topologySpreadConstraints == null) | .metadata.namespace + "/" + .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter_with_var" "$kube_apipath$deployment_apipath" > "$filteredpath"
