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
                    "deployment.kubernetes.io/revision": "5"
                },
                "creationTimestamp": "2022-04-04T12:44:36Z",
                "generation": 5,
                "labels": {
                    "app.kubernetes.io/component": "exporter",
                    "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                    "app.kubernetes.io/name": "kube-state-metrics",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.6.0"
                },
                "name": "kube-state-metrics",
                "namespace": "openshift-monitoring",
                "resourceVersion": "1357677010",
                "uid": "681b1826-0401-4596-a5a1-1b354f569908"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/component": "exporter",
                        "app.kubernetes.io/name": "kube-state-metrics",
                        "app.kubernetes.io/part-of": "openshift-monitoring"
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
                        "annotations": {
                            "kubectl.kubernetes.io/default-container": "kube-state-metrics",
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/component": "exporter",
                            "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                            "app.kubernetes.io/name": "kube-state-metrics",
                            "app.kubernetes.io/part-of": "openshift-monitoring",
                            "app.kubernetes.io/version": "2.6.0"
                        }
                    },
                    "spec": {
                        "automountServiceAccountToken": true,
                        "containers": [
                            {
                                "args": [
                                    "--host=127.0.0.1",
                                    "--port=8081",
                                    "--telemetry-host=127.0.0.1",
                                    "--telemetry-port=8082",
                                    "--metric-denylist=\n^kube_secret_labels$,\n^kube_.+_annotations$\n",
                                    "--metric-labels-allowlist=pods=[*],nodes=[*],namespaces=[*],persistentvolumes=[*],persistentvolumeclaims=[*],poddisruptionbudgets=[*],poddisruptionbudget=[*]",
                                    "--metric-denylist=\n^kube_.+_created$,\n^kube_.+_metadata_resource_version$,\n^kube_replicaset_metadata_generation$,\n^kube_replicaset_status_observed_generation$,\n^kube_pod_restart_policy$,\n^kube_pod_init_container_status_terminated$,\n^kube_pod_init_container_status_running$,\n^kube_pod_container_status_terminated$,\n^kube_pod_container_status_running$,\n^kube_pod_completion_time$,\n^kube_pod_status_scheduled$\n"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:bb0303469ff9ac257efe236775f5c746458e3d55126666de80e460e451dfa383",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-state-metrics",
                                "resources": {
                                    "requests": {
                                        "cpu": "2m",
                                        "memory": "80Mi"
                                    }
                                },
                                "securityContext": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/tmp",
                                        "name": "volume-directive-shadow"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--logtostderr",
                                    "--secure-listen-address=:8443",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--upstream=http://127.0.0.1:8081/",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--client-ca-file=/etc/tls/client/client-ca.crt",
                                    "--config-file=/etc/kube-rbac-policy/config.yaml",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-main",
                                "ports": [
                                    {
                                        "containerPort": 8443,
                                        "name": "https-main",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "securityContext": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "kube-state-metrics-tls"
                                    },
                                    {
                                        "mountPath": "/etc/tls/client",
                                        "name": "metrics-client-ca"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-policy",
                                        "name": "kube-state-metrics-kube-rbac-proxy-config",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--logtostderr",
                                    "--secure-listen-address=:9443",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--upstream=http://127.0.0.1:8082/",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--client-ca-file=/etc/tls/client/client-ca.crt",
                                    "--config-file=/etc/kube-rbac-policy/config.yaml",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-self",
                                "ports": [
                                    {
                                        "containerPort": 9443,
                                        "name": "https-self",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "securityContext": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "kube-state-metrics-tls"
                                    },
                                    {
                                        "mountPath": "/etc/tls/client",
                                        "name": "metrics-client-ca"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-policy",
                                        "name": "kube-state-metrics-kube-rbac-proxy-config",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "node-role.kubernetes.io/infra": ""
                        },
                        "priorityClassName": "system-cluster-critical",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "kube-state-metrics",
                        "serviceAccountName": "kube-state-metrics",
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
                                "name": "volume-directive-shadow"
                            },
                            {
                                "name": "kube-state-metrics-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "kube-state-metrics-tls"
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
                                "name": "kube-state-metrics-kube-rbac-proxy-config",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "kube-state-metrics-kube-rbac-proxy-config"
                                }
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
                    "deployment.kubernetes.io/revision": "3"
                },
                "creationTimestamp": "2023-01-30T10:35:46Z",
                "generation": 3,
                "labels": {
                    "app.kubernetes.io/component": "exporter",
                    "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                    "app.kubernetes.io/name": "openshift-state-metrics",
                    "app.kubernetes.io/part-of": "openshift-monitoring"
                },
                "name": "openshift-state-metrics",
                "namespace": "openshift-monitoring",
                "resourceVersion": "1357676976",
                "uid": "0d4971e0-ec8c-424f-a4f4-ab6041c769d1"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/component": "exporter",
                        "app.kubernetes.io/name": "openshift-state-metrics"
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
                        "annotations": {
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/component": "exporter",
                            "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                            "app.kubernetes.io/name": "openshift-state-metrics",
                            "app.kubernetes.io/part-of": "openshift-monitoring"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "args": [
                                    "--logtostderr",
                                    "--secure-listen-address=:8443",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--upstream=http://127.0.0.1:8081/",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--config-file=/etc/kube-rbac-policy/config.yaml",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-main",
                                "ports": [
                                    {
                                        "containerPort": 8443,
                                        "name": "https-main",
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
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "openshift-state-metrics-tls"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-policy",
                                        "name": "openshift-state-metrics-kube-rbac-proxy-config",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--logtostderr",
                                    "--secure-listen-address=:9443",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--upstream=http://127.0.0.1:8082/",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--config-file=/etc/kube-rbac-policy/config.yaml",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-self",
                                "ports": [
                                    {
                                        "containerPort": 9443,
                                        "name": "https-self",
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
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "openshift-state-metrics-tls"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-policy",
                                        "name": "openshift-state-metrics-kube-rbac-proxy-config",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--host=127.0.0.1",
                                    "--port=8081",
                                    "--telemetry-host=127.0.0.1",
                                    "--telemetry-port=8082"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:5501a4680652bbd1aafd6435771725f6462bd2061f4ebe82a22a66f630bc6f72",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "openshift-state-metrics",
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "32Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File"
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "node-role.kubernetes.io/infra": ""
                        },
                        "priorityClassName": "system-cluster-critical",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "openshift-state-metrics",
                        "serviceAccountName": "openshift-state-metrics",
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
                                "name": "openshift-state-metrics-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "openshift-state-metrics-tls"
                                }
                            },
                            {
                                "name": "openshift-state-metrics-kube-rbac-proxy-config",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "openshift-state-metrics-kube-rbac-proxy-config"
                                }
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
                    "deployment.kubernetes.io/revision": "347"
                },
                "creationTimestamp": "2022-04-04T12:44:37Z",
                "generation": 347,
                "labels": {
                    "app.kubernetes.io/component": "metrics-adapter",
                    "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                    "app.kubernetes.io/name": "prometheus-adapter",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.10.0"
                },
                "name": "prometheus-adapter",
                "namespace": "openshift-monitoring",
                "resourceVersion": "1348266955",
                "uid": "d2c2d49c-dbe6-40a4-85e8-ce9329cb55c0"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/component": "metrics-adapter",
                        "app.kubernetes.io/name": "prometheus-adapter",
                        "app.kubernetes.io/part-of": "openshift-monitoring"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "annotations": {
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/component": "metrics-adapter",
                            "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                            "app.kubernetes.io/name": "prometheus-adapter",
                            "app.kubernetes.io/part-of": "openshift-monitoring",
                            "app.kubernetes.io/version": "0.10.0"
                        }
                    },
                    "spec": {
                        "affinity": {
                            "podAntiAffinity": {
                                "requiredDuringSchedulingIgnoredDuringExecution": [
                                    {
                                        "labelSelector": {
                                            "matchLabels": {
                                                "app.kubernetes.io/component": "metrics-adapter",
                                                "app.kubernetes.io/name": "prometheus-adapter",
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
                        "automountServiceAccountToken": true,
                        "containers": [
                            {
                                "args": [
                                    "--prometheus-auth-config=/etc/prometheus-config/prometheus-config.yaml",
                                    "--config=/etc/adapter/config.yaml",
                                    "--logtostderr=true",
                                    "--metrics-relist-interval=1m",
                                    "--prometheus-url=https://prometheus-k8s.openshift-monitoring.svc:9091",
                                    "--secure-port=6443",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--client-ca-file=/etc/tls/private/client-ca-file",
                                    "--requestheader-client-ca-file=/etc/tls/private/requestheader-client-ca-file",
                                    "--requestheader-allowed-names=kube-apiserver-proxy,system:kube-apiserver-proxy,system:openshift-aggregator",
                                    "--requestheader-extra-headers-prefix=X-Remote-Extra-",
                                    "--requestheader-group-headers=X-Remote-Group",
                                    "--requestheader-username-headers=X-Remote-User",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--audit-policy-file=/etc/audit/metadata-profile.yaml",
                                    "--audit-log-path=/var/log/adapter/audit.log",
                                    "--audit-log-maxsize=100",
                                    "--audit-log-maxbackup=5",
                                    "--audit-log-compress=true",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:3cade03b16237889606ab1e3b1b7fc12d160cacc36ae3df2de05d281bccc7f20",
                                "imagePullPolicy": "IfNotPresent",
                                "livenessProbe": {
                                    "failureThreshold": 5,
                                    "httpGet": {
                                        "path": "/livez",
                                        "port": "https",
                                        "scheme": "HTTPS"
                                    },
                                    "periodSeconds": 5,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "prometheus-adapter",
                                "ports": [
                                    {
                                        "containerPort": 6443,
                                        "name": "https",
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 5,
                                    "httpGet": {
                                        "path": "/readyz",
                                        "port": "https",
                                        "scheme": "HTTPS"
                                    },
                                    "periodSeconds": 5,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
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
                                "startupProbe": {
                                    "failureThreshold": 18,
                                    "httpGet": {
                                        "path": "/livez",
                                        "port": "https",
                                        "scheme": "HTTPS"
                                    },
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/tmp",
                                        "name": "tmpfs"
                                    },
                                    {
                                        "mountPath": "/etc/adapter",
                                        "name": "config"
                                    },
                                    {
                                        "mountPath": "/etc/prometheus-config",
                                        "name": "prometheus-adapter-prometheus-config"
                                    },
                                    {
                                        "mountPath": "/etc/ssl/certs",
                                        "name": "serving-certs-ca-bundle"
                                    },
                                    {
                                        "mountPath": "/etc/audit",
                                        "name": "prometheus-adapter-audit-profiles",
                                        "readOnly": true
                                    },
                                    {
                                        "mountPath": "/var/log/adapter",
                                        "name": "audit-log"
                                    },
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "tls",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "node-role.kubernetes.io/infra": ""
                        },
                        "priorityClassName": "system-cluster-critical",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "prometheus-adapter",
                        "serviceAccountName": "prometheus-adapter",
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
                                "name": "tmpfs"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "prometheus-adapter-prometheus-config"
                                },
                                "name": "prometheus-adapter-prometheus-config"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "items": [
                                        {
                                            "key": "service-ca.crt",
                                            "path": "service-ca.crt"
                                        }
                                    ],
                                    "name": "serving-certs-ca-bundle"
                                },
                                "name": "serving-certs-ca-bundle"
                            },
                            {
                                "emptyDir": {},
                                "name": "audit-log"
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "prometheus-adapter-audit-profiles"
                                },
                                "name": "prometheus-adapter-audit-profiles"
                            },
                            {
                                "name": "tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "prometheus-adapter-6fk0fnclda7g1"
                                }
                            },
                            {
                                "configMap": {
                                    "defaultMode": 420,
                                    "name": "adapter-config"
                                },
                                "name": "config"
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
                    "deployment.kubernetes.io/revision": "2"
                },
                "creationTimestamp": "2023-10-05T11:34:18Z",
                "generation": 2,
                "labels": {
                    "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                    "app.kubernetes.io/name": "prometheus-operator-admission-webhook",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.60.1"
                },
                "name": "prometheus-operator-admission-webhook",
                "namespace": "openshift-monitoring",
                "resourceVersion": "1357676847",
                "uid": "6e07ce87-4124-452f-86ac-124613d0046b"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/name": "prometheus-operator-admission-webhook",
                        "app.kubernetes.io/part-of": "openshift-monitoring"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "annotations": {
                            "kubectl.kubernetes.io/default-container": "prometheus-operator-admission-webhook",
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                            "app.kubernetes.io/name": "prometheus-operator-admission-webhook",
                            "app.kubernetes.io/part-of": "openshift-monitoring",
                            "app.kubernetes.io/version": "0.60.1"
                        }
                    },
                    "spec": {
                        "affinity": {
                            "podAntiAffinity": {
                                "requiredDuringSchedulingIgnoredDuringExecution": [
                                    {
                                        "labelSelector": {
                                            "matchLabels": {
                                                "app.kubernetes.io/name": "prometheus-operator-admission-webhook",
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
                        "automountServiceAccountToken": false,
                        "containers": [
                            {
                                "args": [
                                    "--web.enable-tls=true",
                                    "--web.tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--web.tls-min-version=VersionTLS12",
                                    "--web.cert-file=/etc/tls/private/tls.crt",
                                    "--web.key-file=/etc/tls/private/tls.key"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:7812668217067f9038cc63d1542d3363ccacc30bf9047e2fcb9446136f48ca01",
                                "imagePullPolicy": "IfNotPresent",
                                "livenessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": "https",
                                        "scheme": "HTTPS"
                                    },
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "prometheus-operator-admission-webhook",
                                "ports": [
                                    {
                                        "containerPort": 8443,
                                        "name": "https",
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 3,
                                    "httpGet": {
                                        "path": "/healthz",
                                        "port": "https",
                                        "scheme": "HTTPS"
                                    },
                                    "periodSeconds": 10,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "resources": {
                                    "requests": {
                                        "cpu": "5m",
                                        "memory": "30Mi"
                                    }
                                },
                                "securityContext": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "tls-certificates",
                                        "readOnly": true
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "nodeSelector": {
                            "node-role.kubernetes.io/infra": ""
                        },
                        "priorityClassName": "system-cluster-critical",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "serviceAccount": "prometheus-operator-admission-webhook",
                        "serviceAccountName": "prometheus-operator-admission-webhook",
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
                                "name": "tls-certificates",
                                "secret": {
                                    "defaultMode": 420,
                                    "items": [
                                        {
                                            "key": "tls.crt",
                                            "path": "tls.crt"
                                        },
                                        {
                                            "key": "tls.key",
                                            "path": "tls.key"
                                        }
                                    ],
                                    "secretName": "prometheus-operator-admission-webhook-tls"
                                }
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
                    "deployment.kubernetes.io/revision": "5"
                },
                "creationTimestamp": "2023-01-30T10:35:49Z",
                "generation": 5,
                "labels": {
                    "app.kubernetes.io/component": "query-layer",
                    "app.kubernetes.io/instance": "thanos-querier",
                    "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                    "app.kubernetes.io/name": "thanos-query",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.28.1"
                },
                "name": "thanos-querier",
                "namespace": "openshift-monitoring",
                "resourceVersion": "1357676663",
                "uid": "0a687885-1b09-42d6-8479-311afc4e59c4"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 2,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app.kubernetes.io/component": "query-layer",
                        "app.kubernetes.io/instance": "thanos-querier",
                        "app.kubernetes.io/name": "thanos-query",
                        "app.kubernetes.io/part-of": "openshift-monitoring"
                    }
                },
                "strategy": {
                    "rollingUpdate": {
                        "maxSurge": "25%",
                        "maxUnavailable": 1
                    },
                    "type": "RollingUpdate"
                },
                "template": {
                    "metadata": {
                        "annotations": {
                            "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app.kubernetes.io/component": "query-layer",
                            "app.kubernetes.io/instance": "thanos-querier",
                            "app.kubernetes.io/managed-by": "cluster-monitoring-operator",
                            "app.kubernetes.io/name": "thanos-query",
                            "app.kubernetes.io/part-of": "openshift-monitoring",
                            "app.kubernetes.io/version": "0.28.1"
                        }
                    },
                    "spec": {
                        "affinity": {
                            "podAntiAffinity": {
                                "requiredDuringSchedulingIgnoredDuringExecution": [
                                    {
                                        "labelSelector": {
                                            "matchLabels": {
                                                "app.kubernetes.io/component": "query-layer",
                                                "app.kubernetes.io/instance": "thanos-querier",
                                                "app.kubernetes.io/name": "thanos-query",
                                                "app.kubernetes.io/part-of": "openshift-monitoring"
                                            }
                                        },
                                        "topologyKey": "kubernetes.io/hostname"
                                    }
                                ]
                            }
                        },
                        "containers": [
                            {
                                "args": [
                                    "query",
                                    "--grpc-address=127.0.0.1:10901",
                                    "--http-address=127.0.0.1:9090",
                                    "--log.format=logfmt",
                                    "--query.replica-label=prometheus_replica",
                                    "--query.replica-label=thanos_ruler_replica",
                                    "--store=dnssrv+_grpc._tcp.prometheus-operated.openshift-monitoring.svc.cluster.local",
                                    "--query.auto-downsampling",
                                    "--store.sd-dns-resolver=miekgdns",
                                    "--grpc-client-tls-secure",
                                    "--grpc-client-tls-cert=/etc/tls/grpc/client.crt",
                                    "--grpc-client-tls-key=/etc/tls/grpc/client.key",
                                    "--grpc-client-tls-ca=/etc/tls/grpc/ca.crt",
                                    "--grpc-client-server-name=prometheus-grpc",
                                    "--rule=dnssrv+_grpc._tcp.prometheus-operated.openshift-monitoring.svc.cluster.local",
                                    "--target=dnssrv+_grpc._tcp.prometheus-operated.openshift-monitoring.svc.cluster.local"
                                ],
                                "env": [
                                    {
                                        "name": "HOST_IP_ADDRESS",
                                        "valueFrom": {
                                            "fieldRef": {
                                                "apiVersion": "v1",
                                                "fieldPath": "status.hostIP"
                                            }
                                        }
                                    }
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:a2a0a1b4f08e2c5b3e5c1fe527400315e6532063af6c6e2dce7a0eac79a1d1bf",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "thanos-query",
                                "ports": [
                                    {
                                        "containerPort": 9090,
                                        "name": "http",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "10m",
                                        "memory": "12Mi"
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/grpc",
                                        "name": "secret-grpc-tls"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "-provider=openshift",
                                    "-https-address=:9091",
                                    "-http-address=",
                                    "-email-domain=*",
                                    "-upstream=http://localhost:9090",
                                    "-openshift-service-account=thanos-querier",
                                    "-openshift-sar={\"resource\": \"namespaces\", \"verb\": \"get\"}",
                                    "-openshift-delegate-urls={\"/\": {\"resource\": \"namespaces\", \"verb\": \"get\"}}",
                                    "-tls-cert=/etc/tls/private/tls.crt",
                                    "-tls-key=/etc/tls/private/tls.key",
                                    "-client-secret-file=/var/run/secrets/kubernetes.io/serviceaccount/token",
                                    "-cookie-secret-file=/etc/proxy/secrets/session_secret",
                                    "-openshift-ca=/etc/pki/tls/cert.pem",
                                    "-openshift-ca=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
                                    "-bypass-auth-for=^/-/(healthy|ready)$"
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
                                "livenessProbe": {
                                    "failureThreshold": 4,
                                    "httpGet": {
                                        "path": "/-/healthy",
                                        "port": 9091,
                                        "scheme": "HTTPS"
                                    },
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 30,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "name": "oauth-proxy",
                                "ports": [
                                    {
                                        "containerPort": 9091,
                                        "name": "web",
                                        "protocol": "TCP"
                                    }
                                ],
                                "readinessProbe": {
                                    "failureThreshold": 20,
                                    "httpGet": {
                                        "path": "/-/ready",
                                        "port": 9091,
                                        "scheme": "HTTPS"
                                    },
                                    "initialDelaySeconds": 5,
                                    "periodSeconds": 5,
                                    "successThreshold": 1,
                                    "timeoutSeconds": 1
                                },
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "20Mi"
                                    }
                                },
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-thanos-querier-tls"
                                    },
                                    {
                                        "mountPath": "/etc/proxy/secrets",
                                        "name": "secret-thanos-querier-oauth-cookie"
                                    },
                                    {
                                        "mountPath": "/etc/pki/ca-trust/extracted/pem/",
                                        "name": "thanos-querier-trusted-ca-bundle",
                                        "readOnly": true
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--secure-listen-address=0.0.0.0:9092",
                                    "--upstream=http://127.0.0.1:9095",
                                    "--config-file=/etc/kube-rbac-proxy/config.yaml",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--logtostderr=true",
                                    "--allow-paths=/api/v1/query,/api/v1/query_range,/api/v1/labels,/api/v1/label/*/values,/api/v1/series",
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
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-thanos-querier-tls"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-proxy",
                                        "name": "secret-thanos-querier-kube-rbac-proxy"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--insecure-listen-address=127.0.0.1:9095",
                                    "--upstream=http://127.0.0.1:9090",
                                    "--label=namespace",
                                    "--enable-label-apis",
                                    "--error-on-replace"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:4626710ac6a341bf707b2d5be57607ebc39ddd9d300ca9496e40fcfc75f20f3e",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "prom-label-proxy",
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError"
                            },
                            {
                                "args": [
                                    "--secure-listen-address=0.0.0.0:9093",
                                    "--upstream=http://127.0.0.1:9095",
                                    "--config-file=/etc/kube-rbac-proxy/config.yaml",
                                    "--tls-cert-file=/etc/tls/private/tls.crt",
                                    "--tls-private-key-file=/etc/tls/private/tls.key",
                                    "--tls-cipher-suites=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                                    "--logtostderr=true",
                                    "--allow-paths=/api/v1/rules",
                                    "--tls-min-version=VersionTLS12"
                                ],
                                "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:d63bf13113fa7224bdeb21f4b07d53dce96f9fcc955048b870a97e7c1d054e11",
                                "imagePullPolicy": "IfNotPresent",
                                "name": "kube-rbac-proxy-rules",
                                "ports": [
                                    {
                                        "containerPort": 9093,
                                        "name": "tenancy-rules",
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {
                                    "requests": {
                                        "cpu": "1m",
                                        "memory": "15Mi"
                                    }
                                },
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-thanos-querier-tls"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-proxy",
                                        "name": "secret-thanos-querier-kube-rbac-proxy-rules"
                                    }
                                ]
                            },
                            {
                                "args": [
                                    "--secure-listen-address=0.0.0.0:9094",
                                    "--upstream=http://127.0.0.1:9090",
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
                                "name": "kube-rbac-proxy-metrics",
                                "ports": [
                                    {
                                        "containerPort": 9094,
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
                                "securityContext": {
                                    "allowPrivilegeEscalation": false,
                                    "capabilities": {
                                        "drop": [
                                            "ALL"
                                        ]
                                    }
                                },
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "FallbackToLogsOnError",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/etc/tls/private",
                                        "name": "secret-thanos-querier-tls"
                                    },
                                    {
                                        "mountPath": "/etc/kube-rbac-proxy",
                                        "name": "secret-thanos-querier-kube-rbac-proxy-metrics"
                                    },
                                    {
                                        "mountPath": "/etc/tls/client",
                                        "name": "metrics-client-ca",
                                        "readOnly": true
                                    }
                                ]
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
                            "runAsNonRoot": true,
                            "seccompProfile": {
                                "type": "RuntimeDefault"
                            }
                        },
                        "serviceAccount": "thanos-querier",
                        "serviceAccountName": "thanos-querier",
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
                                "name": "secret-thanos-querier-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-tls"
                                }
                            },
                            {
                                "name": "secret-thanos-querier-oauth-cookie",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-oauth-cookie"
                                }
                            },
                            {
                                "name": "secret-thanos-querier-kube-rbac-proxy",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-kube-rbac-proxy"
                                }
                            },
                            {
                                "name": "secret-thanos-querier-kube-rbac-proxy-rules",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-kube-rbac-proxy-rules"
                                }
                            },
                            {
                                "name": "secret-thanos-querier-kube-rbac-proxy-metrics",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-kube-rbac-proxy-metrics"
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
                                    "name": "thanos-querier-trusted-ca-bundle-b4a61vnd2as9r",
                                    "optional": true
                                },
                                "name": "thanos-querier-trusted-ca-bundle"
                            },
                            {
                                "name": "secret-grpc-tls",
                                "secret": {
                                    "defaultMode": 420,
                                    "secretName": "thanos-querier-grpc-tls-ciisrsmf0gg3i"
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
