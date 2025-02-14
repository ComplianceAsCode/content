#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/statefulsets"

statefulset_apipath="/apis/apps/v1/statefulsets?limit=500"

cat <<EOF > "$kube_apipath$statefulset_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "apps/v1",
            "kind": "StatefulSet",
            "metadata": {
                "creationTimestamp": "2022-05-18T08:17:44Z",
                "generation": 1,
                "labels": {
                    "app.kubernetes.io/instance": "trivy",
                    "app.kubernetes.io/managed-by": "Helm",
                    "app.kubernetes.io/name": "trivy",
                    "app.kubernetes.io/version": "0.27.0",
                    "helm.sh/chart": "trivy-0.4.13"
                },
                "name": "trivy",
                "namespace": "trivy",
                "resourceVersion": "1345155135",
                "uid": "3ff7b9c1-df8f-4531-8534-bf11bdd2124a"
            },
            "spec": {
                "podManagementPolicy": "Parallel",
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/instance": "trivy",
                        "app.kubernetes.io/name": "trivy"
                    }
                },
                "serviceName": "trivy",
                "template": {
                    "metadata": {
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/instance": "trivy",
                            "app.kubernetes.io/name": "trivy"
                        }
                    },
                    "spec": {
                        "automountServiceAccountToken": false,
                        "containers": [
                            {
                                "args": [
                                    "server"
                                ],
                                "envFrom": [
                                    {
                                        "configMapRef": {
                                            "name": "trivy"
                                        }
                                    },
                                    {
                                        "secretRef": {
                                            "name": "trivy"
                                        }
                                    }
                                ],
                                "image": "docker.io/aquasec/trivy:0.27.0",
                                "imagePullPolicy": "IfNotPresent",
                                "livenessProbe": {
                                    "failureThreshold": 10,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": "trivy-http",
                                        "scheme": "HTTP"
                                    },
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "main",
                                "ports": [
                                    {
                                        "containerPort": 4954,
                                        "name": "trivy-http",
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": "trivy-http",
                                        "scheme": "HTTP"
                                    },
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "resources": {
                                    "limits": {
                                        "cpu": "1",
                                        "memory": "1Gi"
                                    },
                                    "requests": {
                                        "cpu": "200m",
                                        "memory": "512Mi"
                                    }
                                },
                                "securityContext": {
                                    "privileged": false,
                                    "readOnlyRootFilesystem": true
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/tmp",
                                        "name": "tmp-data"
                                    },
                                    {
                                        "mountPath": "/home/scanner/.cache",
                                        "name": "data"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "trivy",
                        "serviceAccountName": "trivy",
                        "terminationGracePeriodSeconds": 30,
                        "volumes": [
                            {
                                "emptyDir": {},
                                "name": "tmp-data"
                            }
                        ]
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
                            "name": "data"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "5Gi"
                                }
                            },
                            "volumeMode": "Filesystem"
                        },
                        "status": {
                            "phase": "Pending"
                        }
                    }
                ]
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
