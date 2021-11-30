#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/route.openshift.io/v1"

routes_apipath="/apis/route.openshift.io/v1/routes?limit=500"

# This file assumes that we have no routes outside the openshift/kube namespaces

cat <<EOF > "$kube_apipath$routes_apipath"
{
    "apiVersion": "v1",
    "items": [
        {
            "apiVersion": "route.openshift.io/v1",
            "kind": "Route",
            "metadata": {
                "creationTimestamp": "2021-11-10T16:47:27Z",
                "labels": {
                    "app": "oauth-openshift"
                },
                "name": "oauth-openshift",
                "namespace": "openshift-authentication",
                "resourceVersion": "21582",
                "uid": "265f462c-eb31-43e5-abab-aaad3e34b448"
            },
            "spec": {
                "host": "oauth-openshift.apps.wenshen-51.devcluster.openshift.com",
                "port": {
                    "targetPort": 6443
                },
                "tls": {
                    "insecureEdgeTerminationPolicy": "Redirect",
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
                                "lastTransitionTime": "2021-11-10T16:49:45Z",
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
                "creationTimestamp": "2021-11-10T16:47:49Z",
                "labels": {
                    "app.kubernetes.io/component": "query-layer",
                    "app.kubernetes.io/instance": "thanos-querier",
                    "app.kubernetes.io/name": "thanos-query",
                    "app.kubernetes.io/version": "0.20.2"
                },
                "name": "thanos-querier",
                "namespace": "openshift-monitoring",
                "resourceVersion": "21584",
                "uid": "b36854e4-c909-41d9-b4cb-ad66a76af0f3"
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
                                "lastTransitionTime": "2021-11-10T16:49:45Z",
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
EOF


jq_filter='[.items[] | select(.metadata.namespace | startswith("kube-") or startswith("openshift-") | not) | select(.metadata.annotations["haproxy.router.openshift.io/rate-limit-connections"] == "true" | not) | .metadata.name]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$routes_apipath#$(echo -n "$routes_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$routes_apipath" > "$filteredpath"