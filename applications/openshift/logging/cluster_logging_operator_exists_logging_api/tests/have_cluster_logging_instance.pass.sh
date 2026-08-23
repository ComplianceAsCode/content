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
            "apiVersion": "observability.openshift.io/v1",
            "kind": "ClusterLogForwarder",
            "metadata": {
                "annotations": {
                    "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"observability.openshift.io/v1\",\"kind\":\"ClusterLogForwarder\",\"metadata\":{\"annotations\":{},\"name\":\"instance\",\"namespace\":\"openshift-logging\"},\"spec\":{\"outputs\":[{\"elasticsearch\":{\"index\":\"most-logs\",\"url\":\"https://elasticsearch:9200\",\"version\":6},\"name\":\"default-elasticsearch\",\"type\":\"elasticsearch\"}],\"pipelines\":[{\"inputRefs\":[\"application\",\"audit\",\"infrastructure\"],\"name\":\"most-logs\",\"outputRefs\":[\"default\"]},{\"inputRefs\":[\"audit\"],\"name\":\"audit-logs\",\"outputRefs\":[\"default\"]}],\"serviceAccount\":{\"name\":\"cluster-loggin-operator\"}}}\n"
                },
                "creationTimestamp": "2024-09-30T15:34:24Z",
                "generation": 1,
                "name": "instance",
                "namespace": "openshift-logging",
                "resourceVersion": "95318",
                "uid": "7804fab5-b945-4024-acb7-e89652b5d4f7"
            },
            "spec": {
                "managementState": "Managed",
                "outputs": [
                    {
                        "elasticsearch": {
                            "index": "most-logs",
                            "url": "https://elasticsearch:9200",
                            "version": 6
                        },
                        "name": "default-elasticsearch",
                        "type": "elasticsearch"
                    }
                ],
                "pipelines": [
                    {
                        "inputRefs": [
                            "application",
                            "audit",
                            "infrastructure"
                        ],
                        "name": "most-logs",
                        "outputRefs": [
                            "default"
                        ]
                    },
                    {
                        "inputRefs": [
                            "audit"
                        ],
                        "name": "audit-logs",
                        "outputRefs": [
                            "default"
                        ]
                    }
                ],
                "serviceAccount": {
                    "name": "cluster-loggin-operator"
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
