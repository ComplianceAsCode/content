#!/bin/bash

mkdir -p /kubernetes-api-resources/apis/oauth.openshift.io/v1

cat << EOF > /kubernetes-api-resources/apis/oauth.openshift.io/v1/oauthclients
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "oauth.openshift.io/v1",
            "grantMethod": "auto",
            "kind": "OAuthClient",
            "accessTokenInactivityTimeoutSeconds": "10m0s",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "release.openshift.io/create-only": "true"
                },
                "creationTimestamp": "2022-06-20T15:51:44Z",
                "name": "console",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "e4f746bf-dbf8-40b5-8e8f-7c5f918328c3"
                    }
                ],
                "resourceVersion": "21576",
                "uid": "ba27a93a-2269-40b5-9968-e15a5ce7a8e7"
            },
            "redirectURIs": [
                "https://console-openshift-console.apps.wenshen-51.devcluster.openshift.com/auth/callback"
            ]
        },
        {
            "apiVersion": "oauth.openshift.io/v1",
            "grantMethod": "auto",
            "kind": "OAuthClient",
            "accessTokenInactivityTimeoutSeconds": "600",
            "metadata": {
                "creationTimestamp": "2022-06-20T15:52:50Z",
                "name": "openshift-browser-client",
                "resourceVersion": "21486",
                "uid": "8579d21b-2743-4766-8d0a-7fd20ac4d936"
            },
            "redirectURIs": [
                "https://oauth-openshift.apps.wenshen-51.devcluster.openshift.com/oauth/token/display"
            ]
        },
        {
            "apiVersion": "oauth.openshift.io/v1",
            "grantMethod": "auto",
            "kind": "OAuthClient",
            "accessTokenInactivityTimeoutSeconds": "10m0s",
            "metadata": {
                "creationTimestamp": "2022-06-20T15:52:50Z",
                "name": "openshift-challenging-client",
                "resourceVersion": "21492",
                "uid": "144506bf-484d-49ab-a3de-663aa54d2e69"
            },
            "redirectURIs": [
                "https://oauth-openshift.apps.wenshen-51.devcluster.openshift.com/oauth/token/implicit"
            ],
            "respondWithChallenges": true
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF
