#!/bin/bash


yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/config.openshift.io/v1/clusterversions"

apipath="/apis/config.openshift.io/v1/clusterversions/version"

cat << EOF > $kube_apipath$apipath
{
    "apiVersion": "config.openshift.io/v1",
    "kind": "ClusterVersion",
    "metadata": {
        "creationTimestamp": "2021-12-16T06:23:17Z",
        "generation": 2,
        "name": "version",
        "resourceVersion": "26705",
        "uid": "82964255-cdb8-43c7-b662-f5d4d32a6a1c"
    },
    "spec": {
        "clusterID": "6476f301-185d-468f-ac2e-98144b9aa300"
    },
    "status": {
        "availableUpdates": null,
        "conditions": [
            {
                "lastTransitionTime": "2021-12-16T06:23:17Z",
                "message": "The update channel has not been configured.",
                "reason": "NoChannel",
                "status": "False",
                "type": "RetrievedUpdates"
            },
            {
                "lastTransitionTime": "2021-12-16T06:44:42Z",
                "message": "Done applying 4.10.0-0.ci-2021-12-15-195801",
                "status": "True",
                "type": "Available"
            },
            {
                "lastTransitionTime": "2021-12-16T06:44:42Z",
                "status": "False",
                "type": "Failing"
            },
            {
                "lastTransitionTime": "2021-12-16T06:44:42Z",
                "message": "Cluster version is 4.10.0-0.ci-2021-12-15-195801",
                "status": "False",
                "type": "Progressing"
            }
        ],
        "desired": {
            "image": "registry.build01.ci.openshift.org/ci-ln-vhslt2k/release@sha256:cd38c2c90e01b6c3461afbc6f44743242b9e62fcb4a0c8b7593d7c459a164636",
            "version": "4.10.0-0.ci-2021-12-15-195801"
        },
        "history": [
            {
                "completionTime": "2021-12-16T06:44:42Z",
                "image": "registry.build01.ci.openshift.org/ci-ln-vhslt2k/release@sha256:cd38c2c90e01b6c3461afbc6f44743242b9e62fcb4a0c8b7593d7c459a164636",
                "startedTime": "2021-12-16T06:23:17Z",
                "state": "Completed",
                "verified": true,
                "version": "4.10.0-0.ci-2021-12-15-195801"
            },
            {
                "completionTime": "2021-12-15T06:44:42Z",
                "image": "registry.build01.ci.openshift.org/ci-ln-vhslt2k/release@sha256:cd38c2c90e01b6c3461afbc6f44743242b9e62fcb4a0c8b7593d7c459a164636",
                "startedTime": "2021-12-15T06:23:17Z",
                "state": "Completed",
                "verified": true,
                "version": "4.10.0-0.ci-2021-12-15-195801"
            },
            {
                "completionTime": "2021-12-15T03:44:42Z",
                "image": "registry.build01.ci.openshift.org/ci-ln-vhslt2k/release@sha256:cd38c2c90e01b6c3461afbc6f44743242b9e62fcb4a0c8b7593d7c459a164636",
                "startedTime": "2021-12-15T03:23:17Z",
                "state": "Completed",
                "verified": false,
                "version": "4.10.0-0.ci-2021-12-15-195801"
            }
        ],
        "observedGeneration": 2,
        "versionHash": "nKvpmlDXL0I="
    }
}
EOF

jq_filter='[.status.history[0:-1]|.[]|.verified]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$apipath#$(echo -n "$apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$apipath" > "$filteredpath"