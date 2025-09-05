#!/bin/bash


yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/pipelines.openshift.io/v1alpha1"

apipath="/apis/pipelines.openshift.io/v1alpha1/gitopsservices?limit=5"

cat << EOF > $kube_apipath$apipath
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "pipelines.openshift.io/v1alpha1",
            "kind": "GitopsService",
            "metadata": {
                "creationTimestamp": "2022-04-08T00:23:52Z",
                "generation": 1,
                "name": "cluster",
                "resourceVersion": "16440571",
                "uid": "b89af5df-e903-4221-b4ef-45494560a2ee"
            },
            "spec": {}
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF