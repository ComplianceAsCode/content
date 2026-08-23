#!/bin/bash
# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/observability.openshift.io/v1/namespaces/openshift-logging/"

routes_apipath="/apis/observability.openshift.io/v1/namespaces/openshift-logging/instance"

cat <<EOF > "$kube_apipath$routes_apipath"
{
    "apiVersion": "v1",
    "items": [],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF
