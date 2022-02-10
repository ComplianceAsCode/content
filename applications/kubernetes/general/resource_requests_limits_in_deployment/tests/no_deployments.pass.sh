#!/bin/bash

# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/apps/v1/deployments"

deployment_apipath="/apis/apps/v1/deployments?limit=500"

# This file assumes that we dont have any deployments.
cat <<EOF > "$kube_apipath$deployment_apipath"
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


jq_filter='[ .items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select( .spec.template.spec.containers[].resources.requests.cpu == null  or  .spec.template.spec.containers[].resources.requests.memory == null or .spec.template.spec.containers[].resources.limits.cpu == null  or  .spec.template.spec.containers[].resources.limits.memory == null )  | .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"
