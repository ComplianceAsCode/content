#!/bin/bash
# remediation = none

mkdir -p /kubernetes-api-resources/apis/route.openshift.io/v1/

cat <<EOF > /kubernetes-api-resources/apis/route.openshift.io/v1/routes?limit=500
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "route.openshift.io/v1",
            "kind": "Route",
            "metadata": {
                "creationTimestamp": "2022-02-07T15:44:41Z",
                "labels": {
                    "app": "oauth-openshift"
                },
                "name": "oauth-openshift",
                "namespace": "openshift-authentication",
                "resourceVersion": "20112",
                "uid": "f90675f0-6090-4222-8b41-bf32d522d9ac"
            },
            "spec": {
                "host": "oauth-openshift.apps.wenshen-51.devcluster.openshift.com",
                "port": {
                    "targetPort": 6443
                },
                "tls": {
                    "insecureEdgeTerminationPolicy": "Allow",
                    "termination": "passthrough"
                },
                "to": {
                    "kind": "Service",
                    "name": "oauth-openshift",
                    "weight": 100
                },
                "wildcardPolicy": "None"
            },
            "status": {
                "ingress": [
                    {
                        "conditions": [
                            {
                                "lastTransitionTime": "2022-02-07T15:47:15Z",
                                "status": "True",
                                "type": "Admitted"
                            }
                        ],
                        "host": "oauth-openshift.apps.wenshen-51.devcluster.openshift.com",
                        "routerCanonicalHostname": "router-default.apps.wenshen-51.devcluster.openshift.com",
                        "routerName": "default",
                        "wildcardPolicy": "None"
                    }
                ]
            }
        },
        {
            "apiVersion": "route.openshift.io/v1",
            "kind": "Route",
            "metadata": {
                "annotations": {
                    "openshift.io/host.generated": "true"
                },
                "creationTimestamp": "2022-02-07T15:48:36Z",
                "labels": {
                    "app.kubernetes.io/component": "query-layer",
                    "app.kubernetes.io/instance": "thanos-querier",
                    "app.kubernetes.io/name": "thanos-query",
                    "app.kubernetes.io/version": "0.22.0"
                },
                "name": "thanos-querier",
                "namespace": "openshift-monitoring",
                "resourceVersion": "22723",
                "uid": "a9aee465-0939-466a-a187-5d1c3e97d8e9"
            },
            "spec": {
                "host": "thanos-querier-openshift-monitoring.apps.wenshen-51.devcluster.openshift.com",
                "port": {
                    "targetPort": "web"
                },
                "tls": {
                    "insecureEdgeTerminationPolicy": "Redirect",
                    "termination": "reencrypt"
                },
                "to": {
                    "kind": "Service",
                    "name": "thanos-querier",
                    "weight": 100
                },
                "wildcardPolicy": "None"
            },
            "status": {
                "ingress": [
                    {
                        "conditions": [
                            {
                                "lastTransitionTime": "2022-02-07T15:48:36Z",
                                "status": "True",
                                "type": "Admitted"
                            }
                        ],
                        "host": "thanos-querier-openshift-monitoring.apps.wenshen-51.devcluster.openshift.com",
                        "routerCanonicalHostname": "router-default.apps.wenshen-51.devcluster.openshift.com",
                        "routerName": "default",
                        "wildcardPolicy": "None"
                    }
                ]
            }
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}