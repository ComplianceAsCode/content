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
                "annotations": {
                    "prometheus-operator-input-hash": "13692666772834160214"
                },
                "creationTimestamp": "2023-01-30T10:30:41Z",
                "generation": 44,
                "labels": {
                    "alertmanager": "main",
                    "app.kubernetes.io/component": "alert-router",
                    "app.kubernetes.io/instance": "main",
                    "app.kubernetes.io/name": "alertmanager",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.24.0"
                },
                "name": "alertmanager-main",
                "namespace": "openshift-monitoring",
                "ownerReferences": [
                    {
                        "apiVersion": "monitoring.coreos.com/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Alertmanager",
                        "name": "main",
                        "uid": "ffe3937b-78f2-44b2-961f-71147eee311f"
                    }
                ],
                "resourceVersion": "1357676826",
                "uid": "8f4fda56-13c8-41b6-aa84-c650030da9e2"
            },
            "spec": {
                "podManagementPolicy": "Parallel",
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "alertmanager": "main",
                        "app.kubernetes.io/instance": "main",
                        "app.kubernetes.io/managed-by": "prometheus-operator",
                        "app.kubernetes.io/name": "alertmanager"
                    }
                },
                "serviceName": "alertmanager-operated",
                "template": {
                    "metadata": {
                        "annotations": {
                            "kubectl.kubernetes.io/default-container": "alertmanager",
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "alertmanager": "main",
                            "app.kubernetes.io/component": "alert-router",
                            "app.kubernetes.io/instance": "main",
                            "app.kubernetes.io/managed-by": "prometheus-operator",
                            "app.kubernetes.io/name": "alertmanager",
                            "app.kubernetes.io/part-of": "openshift-monitoring",
                            "app.kubernetes.io/version": "0.24.0"
                        }
                    },
                    "spec": {
                        "affinity": {
                            "podAntiAffinity": {
                                "requiredDuringSchedulingIgnoredDuringExecution": [
                                    {
                                        "labelSelector": {
                                            "matchLabels": {
                                                "app.kubernetes.io/component": "alert-router",
                                                "app.kubernetes.io/instance": "main",
                                                "app.kubernetes.io/name": "alertmanager",
                                                "app.kubernetes.io/part-of": "openshift-monitoring"
                                            }
                                        },
                                        "namespaces": [
                                            "openshift-monitoring"
                                        ],
                                        "topologyKey": "kubernetes.io/hostname"
                                    }
                                ]
                            }
                        },
                        "containers": [
                            {
                                "args": [
                                    "--config.file=/etc/alertmanager/config_out/alertmanager.env.yaml",
                                    "--storage.path=/alertmanager",
                                    "--data.retention=120h",
                                    "--cluster.listen-address=[$(POD_IP)]:9094",
                                    "--web.listen-address=127.0.0.1:9093",
                                    "--web.external-url=https://console-openshift-console.apps.ccloud-ocp-dev.ccloud.ninja/monitoring",
                                    "--web.route-prefix=/",
                                    "--cluster.peer=alertmanager-main-0.alertmanager-operated:9094",
                                    "--cluster.peer=alertmanager-main-1.alertmanager-operated:9094",
                                    "--cluster.reconnect-timeout=5m",
                                    "--web.config.file=/etc/alertmanager/web_config/web-config.yaml"
                                ],
                                "env": [
                                    {
                                        "name": "POD_IP",
                                        "valueFrom": {
                                            "fieldRef": {
                                                "apiVersion": "v1",
                                                "fieldPath": "status.podIP"
                                            }
                                        }
                                    }
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:738076ced738ea22a37704ba3e0dab4925ea85c0c16e41d33556818977358f50",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "alertmanager",
                                "ports": [
                                    {
                                        "containerPort": 9094,
                                        "name": "mesh-tcp",
                                        "protocol": "TCP"
                                    },
                                    {
                                        "containerPort": 9094,
                                        "name": "mesh-udp",
                                        "protocol": "UDP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "4m",
                                        "memory": "40Mi"
                                    }
                                },
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    },
                                    "readOnlyRootFilesystem": true
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/alertmanager/config",
                                        "name": "config-volume"
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/config_out",
                                        "name": "config-out",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/certs",
                                        "name": "tls-assets",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/alertmanager",
                                        "name": "alertmanager-main-db",
                                        "subPath": "alertmanager-db"
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-main-tls",
                                        "name": "secret-alertmanager-main-tls",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-main-proxy",
                                        "name": "secret-alertmanager-main-proxy",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy",
                                        "name": "secret-alertmanager-kube-rbac-proxy",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy-metric",
                                        "name": "secret-alertmanager-kube-rbac-proxy-metric",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/pki/ca-trust/extracted/pem/",
                                        "name": "alertmanager-trusted-ca-bundle",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/web_config/web-config.yaml",
                                        "name": "web-config",
                                        "readOnly": true,
                                        "subPath": "web-config.yaml"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--listen-address=localhost:8080",
                                    "--reload-url=http://localhost:9093/-/reload",
                                    "--config-file=/etc/alertmanager/config/alertmanager.yaml.gz",
                                    "--config-envsubst-file=/etc/alertmanager/config_out/alertmanager.env.yaml",
                                    "--watched-dir=/etc/alertmanager/secrets/alertmanager-main-tls",
                                    "--watched-dir=/etc/alertmanager/secrets/alertmanager-main-proxy",
                                    "--watched-dir=/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy",
                                    "--watched-dir=/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy-metric"
                                ],
                                "command": [
                                    "/bin/prometheus-config-reloader"
                                ],
                                "env": [
                                    {
                                        "name": "POD_NAME",
                                        "valueFrom": {
                                            "fieldRef": {
                                                "apiVersion": "v1",
                                                "fieldPath": "metadata.name"
                                            }
                                        }
                                    },
                                    {
                                        "name": "SHARD",
                                        "value": "-1"
                                    }
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:3cfeba7a98901ea510f476268f0fc520f73329d6bac8939070f20cab36c235dc",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "config-reloader",
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "10Mi"
                                    }
                                },
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    },
                                    "readOnlyRootFilesystem": true
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/alertmanager/config",
                                        "name": "config-volume",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/config_out",
                                        "name": "config-out"
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-main-tls",
                                        "name": "secret-alertmanager-main-tls",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-main-proxy",
                                        "name": "secret-alertmanager-main-proxy",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy",
                                        "name": "secret-alertmanager-kube-rbac-proxy",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/alertmanager/secrets/alertmanager-kube-rbac-proxy-metric",
                                        "name": "secret-alertmanager-kube-rbac-proxy-metric",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "-provider=openshift",
                                    "-https-address=:9095",
                                    "-http-address=",
                                    "-email-domain=*",
                                    "-upstream=http://localhost:9093",
                                    "-openshift-sar=[{\"resource\": \"namespaces\", \"verb\": \"get\"}, {\"resource\": \"alertmanagers\", \"resourceAPIGroup\": \"monitoring.coreos.com\", \"namespace\": \"openshift-monitoring\", \"verb\": \"patch\", \"resourceName\": \"non-existant\"}]",
                                    "-openshift-delegate-urls={\"/\": {\"resource\": \"namespaces\", \"verb\": \"get\"}, \"/\": {\"resource\":\"alertmanagers\", \"group\": \"monitoring.coreos.com\", \"namespace\": \"openshift-monitoring\", \"verb\": \"patch\", \"name\": \"non-existant\"}}",
                                    "-tls-cert=/etc/tls/private/tls.crt",
                                    "-tls-key=/etc/tls/private/tls.key",
                                    "-client-secret-file=/var/run/secrets/kubernetes.io/serviceaccount/token",
                                    "-cookie-secret-file=/etc/proxy/secrets/session_secret",
                                    "-openshift-service-account=alertmanager-main",
                                    "-openshift-ca=/etc/pki/tls/cert.pem",
                                    "-openshift-ca=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                                ],
                                "env": [
                                    {
                                        "name": "HTTP_PROXY"
                                    },
                                    {
                                        "name": "HTTPS_PROXY"
                                    },
                                    {
                                        "name": "NO_PROXY"
                                    }
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:8cee1c6d7316b2108cc2d0272ebf2932ee999c9eb05d5c6e296df362da58e9ce",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "alertmanager-proxy",
                                "ports": [
                                    {
                                        "containerPort": 9095,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "20Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-alertmanager-main-tls"
                                    },
                                    {
                                        "mountPath": "/etc/proxy/secrets",
                                        "name": "secret-alertmanager-main-proxy"
                                    },
                                    {
                                        "mountPath": "/etc/pki/ca-trust/extracted/pem/",
                                        "name": "alertmanager-trusted-ca-bundle",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--secure-listen-address=0.0.0.0:9092",
                                    "--upstream=http://127.0.0.1:9096",
                                    "--config-file=/etc/kube-rbac-proxy/config.yaml",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--logtostderr=true",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy",
                                "ports": [
                                    {
                                        "containerPort": 9092,
                                        "name": "tenancy",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/kube-rbac-proxy",
                                        "name": "secret-alertmanager-kube-rbac-proxy"
                                    },
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-alertmanager-main-tls"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--secure-listen-address=0.0.0.0:9097",
                                    "--upstream=http://127.0.0.1:9093",
                                    "--config-file=/etc/kube-rbac-proxy/config.yaml",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--client-ca-file=/etc/tls/client/client-ca.crt",
                                    "--logtostderr=true",
                                    "--allow-paths=/metrics",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-metric",
                                "ports": [
                                    {
                                        "containerPort": 9097,
                                        "name": "metrics",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/kube-rbac-proxy",
                                        "name": "secret-alertmanager-kube-rbac-proxy-metric",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-alertmanager-main-tls",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/etc/tls/client",
                                        "name": "metrics-client-ca",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--insecure-listen-address=127.0.0.1:9096",
                                    "--upstream=http://127.0.0.1:9093",
                                    "--label=namespace",
                                    "--error-on-replace"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:4626710ac6a341bf707b2d5be57607ebc39ddd9d300ca9496e40fcfc75f20f3e",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "prom-label-proxy",
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "20Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "node-role.kubernetes.io/infra": ""
                        },
                        "priorityClassName": "system-cluster-critical",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {
                            "fsGroup": 65534,
                            "runAsNonRoot": true,
                            "runAsUser": 65534
                        },
                        "serviceAccount": "alertmanager-main",
                        "serviceAccountName": "alertmanager-main",
                        "terminationGracePeriodSeconds": 120,
                        "tolerations": [
                            {
                                "effect": "NoSchedule",
                                "key": "node-role.kubernetes.io/infra",
                                "operator": "Exists"
                            }
                        ],
                        "volumes": [
                            {
                                "name": "config-volume",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-main-generated"
                                }
                            },
                            {
                                "name": "tls-assets",
                                "projected": {
                                    "defaultMode": 420,
                                    "sources": [
                                        {
                                            "secret": {
                                                "name": "alertmanager-main-tls-assets-0"
                                            }
                                        }
                                    ]
                                }
                            },
                            {
                                "emptyDir": {},
                                "name": "config-out"
                            },
                            {
                                "name": "secret-alertmanager-main-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-main-tls"
                                }
                            },
                            {
                                "name": "secret-alertmanager-main-proxy",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-main-proxy"
                                }
                            },
                            {
                                "name": "secret-alertmanager-kube-rbac-proxy",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-kube-rbac-proxy"
                                }
                            },
                            {
                                "name": "secret-alertmanager-kube-rbac-proxy-metric",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-kube-rbac-proxy-metric"
                                }
                            },
                            {
                                "name": "web-config",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "alertmanager-main-web-config"
                                }
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "metrics-client-ca"
                                },
                                "name": "metrics-client-ca"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "items": [
                                        {
                                            "key": "ca-bundle.crt",
                                            "path": "tls-ca-bundle.pem"
                                        }
                                    ],
                                    "name": "alertmanager-trusted-ca-bundle-b4a61vnd2as9r",
                                    "optional": true
                                },
                                "name": "alertmanager-trusted-ca-bundle"
                            }
                        ]
                    }
                },
                "updateStrategy": {
                    "type": "RollingUpdate"
                },
                "volumeClaimTemplates": [
                    {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "metadata": {
                            "creationTimestamp": null,
                            "name": "alertmanager-main-db"
                        },
                        "spec": {
                            "accessModes": [
                                "ReadWriteOnce"
                            ],
                            "resources": {
                                "requests": {
                                    "storage": "10Gi"
                                }
                            },
                            "storageClassName": "ontapnas-ai-at-the-edge-central",
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
