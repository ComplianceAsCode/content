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
                    "deployment.kubernetes.io/revision": "1",
                    "openshift.io/generated-by": "OpenShiftWebConsole"
                },
                "creationTimestamp": "2021-05-18T20:18:35Z",
                "generation": 1,
                "labels": {
                    "app": "nextcloud",
                    "app.kubernetes.io/component": "nextcloud",
                    "app.kubernetes.io/instance": "nextcloud",
                    "app.openshift.io/runtime-namespace": "myapp"
                },
                "name": "nextcloud",
                "namespace": "myapp",
                "resourceVersion": "1303859019",
                "uid": "f3ddd586-f034-41ae-845f-472b7026e966"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 1,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "nextcloud"
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
                            "openshift.io/generated-by": "OpenShiftWebConsole"
                        },
                        "creationTimestamp": null,
                        "labels": {
                            "app": "nextcloud",
                            "deploymentconfig": "nextcloud"
                        }
                    },
                    "spec": {
                        "containers": [
                            {
                                "image": "nextcloud@sha256:3edcc23febe484fff37f9121f96bc634512a56d318477e81316de24cfdec7380",
                                "imagePullPolicy": "Always",
                                "name": "nextcloud",
                                "ports": [
                                    {
                                        "containerPort": 80,
                                        "protocol": "TCP"
                                    }
                                ],
                                "resources": {},
                                "terminationMessagePath": "/dev/termination-log",
                                "terminationMessagePolicy": "File",
                                "volumeMounts": [
                                    {
                                        "mountPath": "/var/www/html",
                                        "name": "nextcloud-1"
                                    }
                                ]
                            }
                        ],
                        "dnsPolicy": "ClusterFirst",
                        "restartPolicy": "Always",
                        "schedulerName": "default-scheduler",
                        "securityContext": {},
                        "terminationGracePeriodSeconds": 30,
                        "volumes": [
                            {
                                "emptyDir": {},
                                "name": "nextcloud-1"
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
                    "deployment.kubernetes.io/revision": "1"
                },
                "creationTimestamp": "2024-07-15T09:40:37Z",
                "generation": 1,
                "labels": {
                    "app": "webserver"
                },
                "name": "webserver",
                "namespace": "myapp",
                "resourceVersion": "1363603995",
                "uid": "5f2f4752-3f8a-4dd6-9c74-e6766336d579"
            },
            "spec": {
                "progressDeadlineSeconds": 600,
                "replicas": 6,
                "revisionHistoryLimit": 10,
                "selector": {
                    "matchLabels": {
                        "app": "webserver"
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
