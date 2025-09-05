#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/apis/route.openshift.io/v1"

routes_apipath="/apis/route.openshift.io/v1/routes"

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
                "creationTimestamp": "2021-11-11T00:26:39Z",
                "labels": {
                    "app": "wordpress",
                    "app.kubernetes.io/component": "wordpress",
                    "app.kubernetes.io/instance": "wordpress"
                },
                "name": "wordpress",
                "namespace": "test-no-rate-limit",
                "resourceVersion": "213342",
                "uid": "26f97c95-7351-49b8-a0dd-f6cdd88283ae"
            },
            "spec": {
                "host": "wordpress-test-no-rate-limit.apps.wenshen-51.devcluster.openshift.com",
                "port": {
                    "targetPort": "8080-tcp"
                },
                "tls": {
                    "insecureEdgeTerminationPolicy": "Redirect",
                    "termination": "passthrough"
                },
                "to": {
                    "kind": "Service",
                    "name": "wordpress",
                    "weight": 100
                },
                "wildcardPolicy": "None"
            },
            "status": {
                "ingress": [
                    {
                        "conditions": [
                            {
                                "lastTransitionTime": "2021-11-11T00:26:39Z",
                                "status": "True",
                                "type": "Admitted"
                            }
                        ],
                        "host": "wordpress-test-no-rate-limit.apps.wenshen-51.devcluster.openshift.com",
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

jq_filter='[.items[] | select(.spec.tls.insecureEdgeTerminationPolicy != null) | select(.spec.tls.insecureEdgeTerminationPolicy | test("^(^$|None|Redirect)$"; "") | not) | .metadata.name]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$routes_apipath#$(echo -n "$routes_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$routes_apipath" > "$filteredpath"