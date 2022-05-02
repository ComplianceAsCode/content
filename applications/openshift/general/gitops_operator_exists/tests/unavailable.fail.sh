#!/bin/bash


yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/pipelines.openshift.io/v1alpha1"

apipath="/apis/pipelines.openshift.io/v1alpha1/gitopsservices?limit=5"

cat << EOF > $kube_apipath$apipath
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