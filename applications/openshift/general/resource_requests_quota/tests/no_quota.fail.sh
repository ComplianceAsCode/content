#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/quota.openshift.io/v1"

quota_apipath="/apis/quota.openshift.io/v1/clusterresourcequotas"

# This file assumes there is no cluster qouta object
cat <<EOF > "$kube_apipath$quota_apipath"
{
    "apiVersion": "v1",
    "items": [
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF

quota_jq_filter='[.items[] | .metadata.name]'

# Get file path. This will actually be read by the scan
quota_filteredpath="$kube_apipath$quota_apipath#$(echo -n "$quota_apipath$quota_jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$quota_jq_filter" "$kube_apipath$quota_apipath" > "$quota_filteredpath"