#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/route.openshift.io/v1"

routes_apipath="/apis/route.openshift.io/v1/routes?limit=500"


# This file assumes that we have no routes

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


jq_filter='[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select(.metadata.annotations["haproxy.router.openshift.io/ip_whitelist"] | not) | .metadata.name]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$routes_apipath#$(echo -n "$routes_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$routes_apipath" > "$filteredpath"