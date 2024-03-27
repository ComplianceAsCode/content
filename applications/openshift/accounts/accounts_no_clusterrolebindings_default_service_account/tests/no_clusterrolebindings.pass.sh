#!/bin/bash
# remediation = none
# packages = jq

kube_apipath="/kubernetes-api-resources"
mkdir -p "$kube_apipath/apis/rbac.authorization.k8s.io/v1"
crb_apipath="/apis/rbac.authorization.k8s.io/v1/clusterrolebindings?limit=10000"

# This file assumes that we dont have any clusterrolebindings.
cat <<EOF > "$kube_apipath$crb_apipath"
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


jq_filter='[.items[] | select ( .subjects[]?.name == "default" ) | select(.subjects[].namespace | startswith("kube-") or startswith("openshift-") | not) | .metadata.name ] | unique'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$crb_apipath#$(echo -n "$crb_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$crb_apipath" > "$filteredpath"
