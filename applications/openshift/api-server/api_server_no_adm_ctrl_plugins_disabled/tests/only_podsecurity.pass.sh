#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/api/v1/namespaces/openshift-kube-apiserver/configmaps"

config_apipath="/api/v1/namespaces/openshift-kube-apiserver/configmaps/config"

cat <<EOF > "$kube_apipath$config_apipath"
{
    "apiVersion": "v1",
    "data": {
        "config.yaml": "{\"apiServerArguments\":{\"allow-privileged\":[\"true\"],\"disable-admission-plugins\":[\"PodSecurity\"]}}"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-01-05T16:43:59Z",
        "name": "config",
        "namespace": "openshift-kube-apiserver",
        "resourceVersion": "18738",
        "uid": "47d65a11-41f3-47d7-ab9a-fb57119e9d81"
    }
}
EOF

jq_filter='[.data."config.yaml" | fromjson | .apiServerArguments | select(has("disable-admission-plugins")) | if ."disable-admission-plugins" != ["PodSecurity"] then ."disable-admission-plugins" else empty end]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$config_apipath#$(echo -n "$config_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$config_apipath" > "$filteredpath"