#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"


# Create infra file for CPE to pass
mkdir -p "$kube_apipath/apis/apps/v1/namespaces/openshift-ingress/deployments"
deployment_apipath="/apis/apps/v1/namespaces/openshift-ingress/deployments/router-default"

cat <<EOF > "$kube_apipath/apis/apps/v1/namespaces/openshift-ingress/deployments/router-default"
{
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {
        "annotations": {
            "deployment.kubernetes.io/revision": "1"
        },
        "creationTimestamp": "2021-10-14T03:50:03Z",
        "generation": 1,
        "labels": {
            "ingresscontroller.operator.openshift.io/owning-ingresscontroller": "default"
        },
        "name": "router-default",
        "namespace": "openshift-ingress",
        "resourceVersion": "1824323",
        "uid": "2c62de4d-5352-4c48-a582-981352e8e6d2"
    },
    "spec": {
        "minReadySeconds": 30,
        "progressDeadlineSeconds": 600,
        "replicas": 1,
        "revisionHistoryLimit": 10,
        "selector": {
            "matchLabels": {
                "ingresscontroller.operator.openshift.io/deployment-ingresscontroller": "default"
            }
        },
        "strategy": {
            "rollingUpdate": {
                "maxSurge": 0,
                "maxUnavailable": "25%"
            },
            "type": "RollingUpdate"
        },
        "template": {
            "metadata": {
                "annotations": {
                    "target.workload.openshift.io/management": "{\"effect\": \"PreferredDuringScheduling\"}",
                    "unsupported.do-not-use.openshift.io/override-liveness-grace-period-seconds": "10"
                },
                "creationTimestamp": null,
                "labels": {
                    "ingresscontroller.operator.openshift.io/deployment-ingresscontroller": "default",
                    "ingresscontroller.operator.openshift.io/hash": "5c7fb4f96"
                }
            },
            "spec": {
                "containers": [
                    {
                        "env": [
                            {
                                "name": "DEFAULT_CERTIFICATE_DIR",
                                "value": "/etc/pki/tls/private"
                            },
                            {
                                "name": "DEFAULT_DESTINATION_CA_PATH",
                                "value": "/var/run/configmaps/service-ca/service-ca.crt"
                            },
                            {
                                "name": "RELOAD_INTERVAL",
                                "value": "5s"
                            },
                            {
                                "name": "ROUTER_ALLOW_WILDCARD_ROUTES",
                                "value": "false"
                            },
                            {
                                "name": "ROUTER_CANONICAL_HOSTNAME",
                                "value": "router-default.apps-crc.testing"
                            },
                            {
                                "name": "ROUTER_CIPHERS",
                                "value": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
                            },
                            {
                                "name": "ROUTER_CIPHERSUITES",
                                "value": "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256"
                            },
                            {
                                "name": "ROUTER_DISABLE_HTTP2",
                                "value": "true"
                            },
                            {
                                "name": "ROUTER_DISABLE_NAMESPACE_OWNERSHIP_CHECK",
                                "value": "false"
                            },
                            {
                                "name": "ROUTER_LOAD_BALANCE_ALGORITHM",
                                "value": "random"
                            },
                            {
                                "name": "ROUTER_METRICS_TLS_CERT_FILE",
                                "value": "/etc/pki/tls/metrics-certs/tls.crt"
                            },
                            {
                                "name": "ROUTER_METRICS_TLS_KEY_FILE",
                                "value": "/etc/pki/tls/metrics-certs/tls.key"
                            },
                            {
                                "name": "ROUTER_METRICS_TYPE",
                                "value": "haproxy"
                            },
                            {
                                "name": "ROUTER_SERVICE_NAME",
                                "value": "default"
                            },
                            {
                                "name": "ROUTER_SERVICE_NAMESPACE",
                                "value": "openshift-ingress"
                            },
                            {
                                "name": "ROUTER_SET_FORWARDED_HEADERS",
                                "value": "append"
                            },
                            {
                                "name": "ROUTER_TCP_BALANCE_SCHEME",
                                "value": "source"
                            },
                            {
                                "name": "ROUTER_THREADS",
                                "value": "4"
                            },
                            {
                                "name": "SSL_MIN_VERSION",
                                "value": "TLSv1.2"
                            },
                            {
                                "name": "STATS_PASSWORD_FILE",
                                "value": "/var/lib/haproxy/conf/metrics-auth/statsPassword"
                            },
                            {
                                "name": "STATS_PORT",
                                "value": "1936"
                            },
                            {
                                "name": "STATS_USERNAME_FILE",
                                "value": "/var/lib/haproxy/conf/metrics-auth/statsUsername"
                            }
                        ],
                        "image": "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:31f370b687d8adf5b9d2b6f8aebbf7bdef8bc8c7adb1012c03ae3bbea1efdc36",
                        "imagePullPolicy": "IfNotPresent",
                        "livenessProbe": {
                            "failureThreshold": 3,
                            "httpGet": {
                                "host": "localhost",
                                "path": "/healthz",
                                "port": 1936,
                                "scheme": "HTTP"
                            },
                            "periodSeconds": 10,
                            "successThreshold": 1,
                            "timeoutSeconds": 1
                        },
                        "name": "router",
                        "ports": [
                            {
                                "containerPort": 80,
                                "hostPort": 80,
                                "name": "http",
                                "protocol": "TCP"
                            },
                            {
                                "containerPort": 443,
                                "hostPort": 443,
                                "name": "https",
                                "protocol": "TCP"
                            },
                            {
                                "containerPort": 1936,
                                "hostPort": 1936,
                                "name": "metrics",
                                "protocol": "TCP"
                            }
                        ],
                        "readinessProbe": {
                            "failureThreshold": 3,
                            "httpGet": {
                                "host": "localhost",
                                "path": "/healthz/ready",
                                "port": 1936,
                                "scheme": "HTTP"
                            },
                            "periodSeconds": 10,
                            "successThreshold": 1,
                            "timeoutSeconds": 1
                        },
                        "resources": {
                            "requests": {
                                "cpu": "100m",
                                "memory": "256Mi"
                            }
                        },
                        "startupProbe": {
                            "failureThreshold": 120,
                            "httpGet": {
                                "host": "localhost",
                                "path": "/healthz/ready",
                                "port": 1936,
                                "scheme": "HTTP"
                            },
                            "periodSeconds": 1,
                            "successThreshold": 1,
                            "timeoutSeconds": 1
                        },
                        "terminationMessagePath": "/dev/termination-log",
                        "terminationMessagePolicy": "FallbackToLogsOnError",
                        "volumeMounts": [
                            {
                                "mountPath": "/etc/pki/tls/private",
                                "name": "default-certificate",
                                "readOnly": true
                            },
                            {
                                "mountPath": "/var/run/configmaps/service-ca",
                                "name": "service-ca-bundle",
                                "readOnly": true
                            },
                            {
                                "mountPath": "/var/lib/haproxy/conf/metrics-auth",
                                "name": "stats-auth",
                                "readOnly": true
                            },
                            {
                                "mountPath": "/etc/pki/tls/metrics-certs",
                                "name": "metrics-certs",
                                "readOnly": true
                            }
                        ]
                    }
                ],
                "dnsPolicy": "ClusterFirstWithHostNet",
                "hostNetwork": true,
                "nodeSelector": {
                    "kubernetes.io/os": "linux",
                    "node-role.kubernetes.io/worker": ""
                },
                "priorityClassName": "system-cluster-critical",
                "restartPolicy": "Always",
                "schedulerName": "default-scheduler",
                "securityContext": {},
                "serviceAccount": "router",
                "serviceAccountName": "router",
                "terminationGracePeriodSeconds": 3600,
                "topologySpreadConstraints": [
                    {
                        "labelSelector": {
                            "matchExpressions": [
                                {
                                    "key": "ingresscontroller.operator.openshift.io/hash",
                                    "operator": "In",
                                    "values": [
                                        "5c7fb4f96"
                                    ]
                                }
                            ]
                        },
                        "maxSkew": 1,
                        "topologyKey": "topology.kubernetes.io/zone",
                        "whenUnsatisfiable": "ScheduleAnyway"
                    }
                ],
                "volumes": [
                    {
                        "name": "default-certificate",
                        "secret": {
                            "defaultMode": 420,
                            "secretName": "router-certs-default"
                        }
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
                            "name": "service-ca-bundle",
                            "optional": false
                        },
                        "name": "service-ca-bundle"
                    },
                    {
                        "name": "stats-auth",
                        "secret": {
                            "defaultMode": 420,
                            "secretName": "router-stats-default"
                        }
                    },
                    {
                        "name": "metrics-certs",
                        "secret": {
                            "defaultMode": 420,
                            "secretName": "router-metrics-certs-default"
                        }
                    }
                ]
            }
        }
    },
    "status": {
        "availableReplicas": 1,
        "conditions": [
            {
                "lastTransitionTime": "2021-10-14T03:50:09Z",
                "lastUpdateTime": "2021-10-14T03:50:09Z",
                "message": "Deployment has minimum availability.",
                "reason": "MinimumReplicasAvailable",
                "status": "True",
                "type": "Available"
            },
            {
                "lastTransitionTime": "2021-10-14T03:50:09Z",
                "lastUpdateTime": "2021-10-14T03:53:12Z",
                "message": "ReplicaSet \"router-default-7c99985dcd\" has successfully progressed.",
                "reason": "NewReplicaSetAvailable",
                "status": "True",
                "type": "Progressing"
            }
        ],
        "observedGeneration": 1,
        "readyReplicas": 1,
        "replicas": 1,
        "updatedReplicas": 1
    }
}
EOF


jq_filter='.spec.template.spec.containers[0].env[] | select(.name == "SSL_MIN_VERSION")'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"
