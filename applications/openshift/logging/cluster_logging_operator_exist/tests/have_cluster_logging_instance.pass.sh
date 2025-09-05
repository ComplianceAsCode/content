#!/bin/bash
# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/logging.openshift.io/v1/namespaces/openshift-logging/"

routes_apipath="/apis/logging.openshift.io/v1/namespaces/openshift-logging/instance"

cat <<EOF > "$kube_apipath$routes_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "logging.openshift.io/v1",
            "kind": "ClusterLogging",
            "metadata": {
                "creationTimestamp": "2022-04-07T22:31:00Z",
                "generation": 1,
                "name": "instance",
                "namespace": "openshift-logging",
                "resourceVersion": "16375545",
                "uid": "dcc9e26d-934d-4dca-9e88-dcbc6b85c669"
            },
            "spec": {
                "collection": {
                    "logs": {
                        "fluentd": {},
                        "type": "fluentd"
                    }
                },
                "curation": {
                    "curator": {
                        "schedule": "30 3,9,15,21 * * *"
                    },
                    "type": "curator"
                },
                "logStore": {
                    "elasticsearch": {
                        "nodeCount": 1,
                        "redundancyPolicy": "ZeroRedundancy",
                        "resources": {
                            "limits": {
                                "cpu": "500m",
                                "memory": "4Gi"
                            }
                        },
                        "storage": {}
                    },
                    "type": "elasticsearch"
                },
                "managementState": "Managed",
                "visualization": {
                    "kibana": {
                        "replicas": 1
                    },
                    "type": "kibana"
                }
            },
            "status": {
                "collection": {
                    "logs": {
                        "fluentdStatus": {}
                    }
                },
                "curation": {},
                "logStore": {},
                "visualization": {}
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
