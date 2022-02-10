#!/bin/bash
# remediation = none

mkdir -p /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/
cat << EOF >> /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/roles?limit=1000
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
