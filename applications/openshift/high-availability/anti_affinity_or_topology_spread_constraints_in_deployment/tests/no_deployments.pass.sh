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


jq_filter='[ .items[] | select(.metadata.name | test("{{.var_deployments_without_high_availability}}"; "") | not) | select (.spec.replicas == 0 or .spec.replicas == 1 | not) | select(.spec.template.spec.affinity.podAntiAffinity == null and .spec.template.spec.topologySpreadConstraints == null) | .metadata.namespace + "/" + .metadata.name ]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$deployment_apipath#$(echo -n "$deployment_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$deployment_apipath" > "$filteredpath"
