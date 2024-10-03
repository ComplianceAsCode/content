#!/bin/bash
# remediation = none

mkdir -p /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/
cat << EOF >> /kubernetes-api-resources/apis/rbac.authorization.k8s.io/v1/clusterroles?limit=1000
{
    "apiVersion": "v1",
    "items": [
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "admin",
                "resourceVersion": "41134",
                "uid": "0581700d-e426-4b01-b172-dccd715eaca3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "subscriptions"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy",
                        "secrets",
                        "services/proxy"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "events",
                        "persistentvolumeclaims",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "secrets",
                        "serviceaccounts",
                        "services",
                        "services/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "replicasets",
                        "replicasets/scale",
                        "statefulsets",
                        "statefulsets/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "ingresses",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete",
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate",
                        "buildconfigs/instantiatebinary",
                        "builds/clone"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "edit",
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigrollbacks",
                        "deploymentconfigs/instantiate",
                        "deploymentconfigs/rollback"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "delete",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "resourceaccessreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicyreviews",
                        "podsecuritypolicyselfsubjectreviews",
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "rolebindingrestrictions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "admin",
                        "edit",
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "aggregate-olm-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2249",
                "uid": "fb697b04-3cf2-4d4d-b132-2b762b3028ca"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "subscriptions"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions"
                    ],
                    "verbs": [
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "aggregate-olm-view",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2259",
                "uid": "2a8ddd24-f3d9-4fe5-a8fc-84bbb8eb3c8e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:15Z",
                "name": "alertmanager-main",
                "resourceVersion": "19894",
                "uid": "c8c51c50-12ba-4653-8cbd-079917d46694"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:56Z",
                "name": "aws-ebs-csi-driver-operator-clusterrole",
                "resourceVersion": "5137",
                "uid": "a69ed4d7-2d1e-453c-af15-24b9d669e3db"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "clustercsidrivers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "clustercsidrivers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "extension-apiserver-authentication",
                        "aws-ebs-csi-driver-operator-lock"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles",
                        "clusterrolebindings",
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "create",
                        "delete",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "list",
                        "create",
                        "watch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "patch",
                        "delete",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "list",
                        "get",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets",
                        "replicasets",
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete",
                        "create",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents/status"
                    ],
                    "verbs": [
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses",
                        "csinodes"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "create",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "cloudcredential.openshift.io"
                    ],
                    "resources": [
                        "credentialsrequests"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "proxies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "authorization.openshift.io/aggregate-to-basic-user": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "A user that can get basic information about projects.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "basic-user",
                "resourceVersion": "9596",
                "uid": "5a7ae3f1-38ad-4b44-993d-e73a45a24ff7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resourceNames": [
                        "~"
                    ],
                    "resources": [
                        "users"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "selfsubjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "selfsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:13Z",
                "name": "cloud-controller-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2168",
                "uid": "63e9bfac-88b4-46de-b324-7a62b06cdd59"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts/token"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:39Z",
                "name": "cloud-credential-operator-role",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1290",
                "uid": "efdab34a-3b34-4f2d-8f72-bdfd92c3e726"
            },
            "rules": [
                {
                    "apiGroups": [
                        "cloudcredential.openshift.io"
                    ],
                    "resources": [
                        "credentialsrequests",
                        "credentialsrequests/status",
                        "credentialsrequests/finalizers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "configmaps",
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusterversions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "dnses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status",
                        "authentications"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles",
                        "clusterrolebindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "cloudcredentials"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:14Z",
                "name": "cloud-node-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2253",
                "uid": "7446df58-8536-45a7-9a09-dbd7363e5df5"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "cluster-admin",
                "resourceVersion": "98",
                "uid": "a36929b8-6217-4a22-b56e-714a48137418"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:13Z",
                "labels": {
                    "k8s-addon": "cluster-autoscaler.addons.k8s.io",
                    "k8s-app": "cluster-autoscaler"
                },
                "name": "cluster-autoscaler",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2184",
                "uid": "105c7103-d9de-40d6-9790-37f447c427c3"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events",
                        "endpoints"
                    ],
                    "verbs": [
                        "create",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/eviction"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "cluster-autoscaler"
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "replicationcontrollers",
                        "persistentvolumeclaims",
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "replicasets",
                        "daemonsets"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets",
                        "replicasets",
                        "daemonsets"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses",
                        "csinodes",
                        "csidrivers",
                        "csistoragecapacities"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "cluster.k8s.io",
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machinedeployments",
                        "machines",
                        "machinesets",
                        "machinesets/scale"
                    ],
                    "verbs": [
                        "watch",
                        "list",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resourceNames": [
                        "cluster-autoscaler"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:33Z",
                "name": "cluster-autoscaler-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1131",
                "uid": "4eda024f-bb48-4145-af78-fbbc1266bd00"
            },
            "rules": [
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:11Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "cluster-autoscaler-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "9050",
                "uid": "449ed970-724b-4bfb-b927-88e594db9f7c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "autoscaling.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "name": "cluster-baremetal-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2263",
                "uid": "9aacfe9e-b9c8-47d4-a95c-e8342733e61c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets",
                        "services"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "infrastructures/status"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "baremetalhosts"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "baremetalhosts/finalizers",
                        "baremetalhosts/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "firmwareschemas"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "hostfirmwaresettings"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "hostfirmwaresettings/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "preprovisioningimages"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "preprovisioningimages/status"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "provisionings",
                        "provisionings/finalizers"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metal3.io"
                    ],
                    "resources": [
                        "provisionings/status"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "cluster-debugger",
                "resourceVersion": "9567",
                "uid": "0bfd01ab-672d-4079-b251-bb770830fb54"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/debug/pprof",
                        "/debug/pprof/*",
                        "/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:59Z",
                "name": "cluster-image-registry-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1774",
                "uid": "7bc623bc-02ab-487f-b74b-d18599157348"
            },
            "rules": [
                {
                    "apiGroups": [
                        "imageregistry.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "configs/status",
                        "imagepruners",
                        "imagepruners/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "images",
                        "images/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "events",
                        "namespaces",
                        "persistentvolumeclaims",
                        "pods",
                        "secrets",
                        "services"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles",
                        "clusterrolebindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "limitranges",
                        "resourcequotas"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes",
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:53Z",
                "name": "cluster-monitoring-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1663",
                "uid": "44a44b4b-8034-43da-8c16-7b1fc948abba"
            },
            "rules": [
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings",
                        "clusterroles",
                        "clusterrolebindings"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resourceNames": [
                        "prometheusrules.openshift.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apiregistration.k8s.io"
                    ],
                    "resources": [
                        "apiservices"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusterversions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "cluster"
                    ],
                    "resources": [
                        "apiservers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/approval",
                        "certificatesigningrequests/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "user-workload-monitoring-config"
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets",
                        "nodes",
                        "pods",
                        "services",
                        "resourcequotas",
                        "replicationcontrollers",
                        "limitranges",
                        "persistentvolumeclaims",
                        "persistentvolumes",
                        "namespaces",
                        "endpoints"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets",
                        "daemonsets",
                        "deployments",
                        "replicasets"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses",
                        "volumeattachments"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies",
                        "ingresses"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "node-exporter"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "builds"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "user.openshift.io"
                    ],
                    "resources": [
                        "groups"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes",
                        "namespaces",
                        "pods",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "alertmanagers",
                        "alertmanagers/finalizers",
                        "alertmanagerconfigs",
                        "prometheuses",
                        "prometheuses/finalizers",
                        "thanosrulers",
                        "thanosrulers/finalizers",
                        "servicemonitors",
                        "podmonitors",
                        "probes",
                        "prometheusrules"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "services/finalizers",
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:51Z",
                "name": "cluster-monitoring-operator-namespaced",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1604",
                "uid": "9cc85e05-ad4b-4fd5-a4bb-8d11a10c9613"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "serviceaccounts",
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "name": "cluster-monitoring-view",
                "resourceVersion": "8353",
                "uid": "e6fe5421-5b0a-4dc4-999e-6d1cbc9da012"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:57Z",
                "name": "cluster-node-tuning-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1730",
                "uid": "0295deed-187c-4fc9-8fc7-a2b513be7caa"
            },
            "rules": [
                {
                    "apiGroups": [
                        "tuned.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "delete",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "delete",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics",
                        "nodes/specs"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "delete",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:03Z",
                "name": "cluster-node-tuning:tuned",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1859",
                "uid": "f9ec93d9-8cf0-4ad8-92c4-3426351268e9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "tuned.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "rbac.authorization.k8s.io/aggregate-to-view": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "cluster-reader",
                "resourceVersion": "41131",
                "uid": "03a5e84d-30f7-4f91-94cf-14623f8fdaa6"
            },
            "rules": [
                {
                    "apiGroups": [
                        "autoscaling.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machinehealthchecks",
                        "machines",
                        "machinesets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "operatorhubs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "componentstatuses",
                        "nodes",
                        "nodes/status",
                        "persistentvolumeclaims/status",
                        "persistentvolumes",
                        "persistentvolumes/status",
                        "pods/binding",
                        "pods/eviction",
                        "podtemplates",
                        "securitycontextconstraints",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets/status",
                        "deployments/status",
                        "replicasets/status",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions",
                        "customresourcedefinitions/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiregistration.k8s.io"
                    ],
                    "resources": [
                        "apiservices",
                        "apiservices/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs/status",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "node.k8s.io"
                    ],
                    "resources": [
                        "runtimeclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets/status",
                        "podsecuritypolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers",
                        "csinodes",
                        "storageclasses",
                        "volumeattachments",
                        "volumeattachments/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "scheduling.k8s.io"
                    ],
                    "resources": [
                        "priorityclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests",
                        "certificatesigningrequests/approval",
                        "certificatesigningrequests/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindingrestrictions",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "imagesignatures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "oauth.openshift.io"
                    ],
                    "resources": [
                        "oauthclientauthorizations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas",
                        "clusterresourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "clusternetworks",
                        "egressnetworkpolicies",
                        "hostsubnets",
                        "netnamespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "rangeallocations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "brokertemplateinstances",
                        "templateinstances/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resources": [
                        "groups",
                        "identities",
                        "useridentitymappings",
                        "users"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "resourceaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews",
                        "selfsubjectaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicyreviews",
                        "podsecuritypolicyselfsubjectreviews",
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics",
                        "nodes/spec"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/stats"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "cloudcredential.openshift.io"
                    ],
                    "resources": [
                        "credentialsrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "apiservers",
                        "authentications",
                        "builds",
                        "clusteroperators",
                        "clusterversions",
                        "consoles",
                        "dnses",
                        "featuregates",
                        "images",
                        "infrastructures",
                        "ingresses",
                        "networks",
                        "oauths",
                        "projects",
                        "proxies",
                        "schedulers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "samples.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "configs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "containerruntimeconfigs",
                        "controllerconfigs",
                        "kubeletconfigs",
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:59Z",
                "name": "cluster-samples-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1792",
                "uid": "1a5bd458-c4dc-4f19-8d36-be2259253e31"
            },
            "rules": [
                {
                    "apiGroups": [
                        "samples.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "configs/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:51Z",
                "name": "cluster-samples-operator-imageconfig-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1602",
                "uid": "1ab82ae2-9fcd-4445-8fb2-6ef7cbb2ec82"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "images"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:56Z",
                "name": "cluster-samples-operator-proxy-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1685",
                "uid": "e32c9c70-7d55-44a5-9523-da9e06cdc033"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "A user that can get basic cluster status information.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "cluster-status",
                "resourceVersion": "9600",
                "uid": "75ed7b44-eb60-42d0-818a-cb2e4c66256a"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/healthz",
                        "/healthz/"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "/version",
                        "/version/*",
                        "/api",
                        "/api/*",
                        "/apis",
                        "/apis/*",
                        "/oapi",
                        "/oapi/*",
                        "/openapi/v2",
                        "/swaggerapi",
                        "/swaggerapi/*",
                        "/swagger.json",
                        "/swagger-2.0.0.pb-v1",
                        "/osapi",
                        "/osapi/",
                        "/.well-known",
                        "/.well-known/oauth-authorization-server",
                        "/"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "name": "compliance-operator-metrics",
                "resourceVersion": "40549",
                "uid": "7a5ae16f-aa42-460e-b62f-d8b7c4e459aa"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "/metrics",
                        "/metrics-co"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-5bf7f9bbcd",
                "resourceVersion": "40713",
                "uid": "fba5c10d-05e0-4256-b71e-28bf44a2bad6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes",
                        "namespaces"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs",
                        "machineconfigpools",
                        "kubeletconfigs"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "patch",
                        "create",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "cluster"
                    ],
                    "resources": [
                        "apiservers",
                        "oauths"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "prometheusrules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "create",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "templates.gatekeeper.sh"
                    ],
                    "resources": [
                        "constrainttemplates"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "patch",
                        "create",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "config.gatekeeper.sh"
                    ],
                    "resources": [
                        "configs"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "patch",
                        "create",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "constraints.gatekeeper.sh"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "patch",
                        "create",
                        "watch",
                        "update",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:35Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-5c487d6fd6",
                "resourceVersion": "40701",
                "uid": "2f7320d5-2221-4084-a59f-4fb1413e5034"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "ingresscontrollers",
                        "kubeapiservers",
                        "openshiftapiservers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "operatorhubs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "componentstatuses",
                        "nodes",
                        "nodes/status",
                        "persistentvolumeclaims/status",
                        "persistentvolumes",
                        "persistentvolumes/status",
                        "pods/binding",
                        "pods/eviction",
                        "podtemplates",
                        "securitycontextconstraints",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets/status",
                        "deployments/status",
                        "replicasets/status",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions",
                        "customresourcedefinitions/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiregistration.k8s.io"
                    ],
                    "resources": [
                        "apiservices",
                        "apiservices/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs/status",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets/status",
                        "deployments/status",
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status",
                        "ingresses/status",
                        "jobs",
                        "jobs/status",
                        "podsecuritypolicies",
                        "replicasets/status",
                        "replicationcontrollers",
                        "storageclasses",
                        "thirdpartyresources"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "node.k8s.io"
                    ],
                    "resources": [
                        "runtimeclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets/status",
                        "podsecuritypolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "settings.k8s.io"
                    ],
                    "resources": [
                        "podpresets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers",
                        "csinodes",
                        "storageclasses",
                        "volumeattachments",
                        "volumeattachments/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "scheduling.k8s.io"
                    ],
                    "resources": [
                        "priorityclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests",
                        "certificatesigningrequests/approval",
                        "certificatesigningrequests/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindingrestrictions",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "imagesignatures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "oauth.openshift.io"
                    ],
                    "resources": [
                        "oauthclientauthorizations",
                        "oauthclients"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas",
                        "clusterresourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "clusternetworks",
                        "egressnetworkpolicies",
                        "hostsubnets",
                        "netnamespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "rangeallocations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "brokertemplateinstances",
                        "templateinstances/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resources": [
                        "groups",
                        "identities",
                        "useridentitymappings",
                        "users"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "resourceaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews",
                        "selfsubjectaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicyreviews",
                        "podsecuritypolicyselfsubjectreviews",
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics",
                        "nodes/spec"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/stats"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "cloudcredential.openshift.io"
                    ],
                    "resources": [
                        "credentialsrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "apiservers",
                        "authentications",
                        "builds",
                        "clusteroperators",
                        "clusterversions",
                        "consoles",
                        "dnses",
                        "featuregates",
                        "images",
                        "infrastructures",
                        "ingresses",
                        "networks",
                        "oauths",
                        "projects",
                        "proxies",
                        "schedulers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "samples.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "configs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "containerruntimeconfigs",
                        "controllerconfigs",
                        "kubeletconfigs",
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "observability.openshift.io"
                    ],
                    "resources": [
                        "clusterlogforwarders"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "flowcontrol.apiserver.k8s.io"
                    ],
                    "resourceNames": [
                        "catch-all"
                    ],
                    "resources": [
                        "flowschemas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resourceNames": [
                        "cluster"
                    ],
                    "resources": [
                        "kubeapiservers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs",
                        "kubeletconfigs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "fileintegrity.openshift.io"
                    ],
                    "resources": [
                        "fileintegrities"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "prometheusrules"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "kubeadmin"
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:34Z",
                "labels": {
                    "olm.owner": "compliance-operator.v0.1.44",
                    "olm.owner.kind": "ClusterServiceVersion",
                    "olm.owner.namespace": "openshift-compliance",
                    "operators.coreos.com/compliance-operator.openshift-compliance": ""
                },
                "name": "compliance-operator.v0.1.44-7b8fcbdb67",
                "resourceVersion": "40708",
                "uid": "d41a4b7e-65ef-43dc-a3a8-740348705a17"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services",
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "/metrics",
                        "/metrics-co"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "compliancecheckresults.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancecheckresults.compliance.openshift.io",
                        "uid": "d8f03e0e-b3c7-4c6b-b637-b40160b8bb78"
                    }
                ],
                "resourceVersion": "40905",
                "uid": "2287b644-3e8c-40ab-8273-37175b26e956"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancecheckresults.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancecheckresults.compliance.openshift.io",
                        "uid": "d8f03e0e-b3c7-4c6b-b637-b40160b8bb78"
                    }
                ],
                "resourceVersion": "40919",
                "uid": "465d2db4-f5ad-4866-a9ca-768e7421d5de"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "compliancecheckresults.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancecheckresults.compliance.openshift.io",
                        "uid": "d8f03e0e-b3c7-4c6b-b637-b40160b8bb78"
                    }
                ],
                "resourceVersion": "40908",
                "uid": "139d6b1e-87d6-4b8d-8c81-24c24e161df5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancecheckresults.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancecheckresults.compliance.openshift.io",
                        "uid": "d8f03e0e-b3c7-4c6b-b637-b40160b8bb78"
                    }
                ],
                "resourceVersion": "40912",
                "uid": "1ea23d02-7890-417f-8851-048b384d9da7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "complianceremediations.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "complianceremediations.compliance.openshift.io",
                        "uid": "fc78ad3f-2f7b-460f-a866-011fa140fe11"
                    }
                ],
                "resourceVersion": "40924",
                "uid": "95a5c2fc-cbd4-43a7-b123-f3fba70e516b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "complianceremediations.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "complianceremediations.compliance.openshift.io",
                        "uid": "fc78ad3f-2f7b-460f-a866-011fa140fe11"
                    }
                ],
                "resourceVersion": "40940",
                "uid": "bd156fd1-ac02-497e-8c5a-2165323c9e46"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "complianceremediations.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "complianceremediations.compliance.openshift.io",
                        "uid": "fc78ad3f-2f7b-460f-a866-011fa140fe11"
                    }
                ],
                "resourceVersion": "40928",
                "uid": "043c0f8b-12b6-44b7-83b4-818267bc51e2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:55Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "complianceremediations.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "complianceremediations.compliance.openshift.io",
                        "uid": "fc78ad3f-2f7b-460f-a866-011fa140fe11"
                    }
                ],
                "resourceVersion": "40933",
                "uid": "f369736c-1cb2-40dd-bd66-82ca23027541"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "compliancescans.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancescans.compliance.openshift.io",
                        "uid": "f58e817b-5a2c-4c48-bc23-d15993eb4a13"
                    }
                ],
                "resourceVersion": "40956",
                "uid": "a6e5c13f-7d5a-4fd7-9ed2-9c0a245a9883"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancescans.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancescans.compliance.openshift.io",
                        "uid": "f58e817b-5a2c-4c48-bc23-d15993eb4a13"
                    }
                ],
                "resourceVersion": "40960",
                "uid": "4f46067e-e90d-4268-b3ac-0e1ee503efa4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "compliancescans.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancescans.compliance.openshift.io",
                        "uid": "f58e817b-5a2c-4c48-bc23-d15993eb4a13"
                    }
                ],
                "resourceVersion": "40946",
                "uid": "546508f7-2c8e-4c74-868b-64c7bc616f5e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancescans.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancescans.compliance.openshift.io",
                        "uid": "f58e817b-5a2c-4c48-bc23-d15993eb4a13"
                    }
                ],
                "resourceVersion": "40951",
                "uid": "a6a04ead-e04a-49c7-a470-faed394d98b8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "compliancesuites.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancesuites.compliance.openshift.io",
                        "uid": "7d704147-9d8f-4546-b750-807db2fb0acf"
                    }
                ],
                "resourceVersion": "40966",
                "uid": "7104732a-4fb3-4e3a-88ac-03ea8a773662"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancesuites.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancesuites.compliance.openshift.io",
                        "uid": "7d704147-9d8f-4546-b750-807db2fb0acf"
                    }
                ],
                "resourceVersion": "40981",
                "uid": "6e71ad7c-0a81-4c03-8a19-c7bcb8c5c834"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "compliancesuites.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancesuites.compliance.openshift.io",
                        "uid": "7d704147-9d8f-4546-b750-807db2fb0acf"
                    }
                ],
                "resourceVersion": "40969",
                "uid": "31a619b1-524a-43ab-8562-b2c0f2a29264"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "compliancesuites.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "compliancesuites.compliance.openshift.io",
                        "uid": "7d704147-9d8f-4546-b750-807db2fb0acf"
                    }
                ],
                "resourceVersion": "40975",
                "uid": "4c696aac-afa2-4a3d-b021-95ae3f3df025"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:09Z",
                "name": "console",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12060",
                "uid": "ac9bf7bb-608b-47ef-9359-08aa8b0084b8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resourceNames": [
                        "web-terminal"
                    ],
                    "resources": [
                        "subscriptions"
                    ],
                    "verbs": [
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:07Z",
                "name": "console-extensions-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12056",
                "uid": "4d06f47c-b678-4fdc-abdf-ba628c003e19"
            },
            "rules": [
                {
                    "apiGroups": [
                        "console.openshift.io"
                    ],
                    "resources": [
                        "consolelinks",
                        "consolenotifications",
                        "consoleexternalloglinks",
                        "consoleclidownloads",
                        "consoleyamlsamples",
                        "consolequickstarts",
                        "consoleplugins"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:08Z",
                "name": "console-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12058",
                "uid": "6d3a2121-f2cb-48d0-bb0e-667980b21e6f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "oauth.openshift.io"
                    ],
                    "resourceNames": [
                        "console"
                    ],
                    "resources": [
                        "oauthclients"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "oauths"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "consoles",
                        "consoles/status",
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "consoles",
                        "consoles/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "console.openshift.io"
                    ],
                    "resources": [
                        "consoleclidownloads"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:10Z",
                "name": "dns-monitoring",
                "resourceVersion": "6493",
                "uid": "c9d1c0b2-9a88-4e4e-8997-ec1c04d1e1cd"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "dnses"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "ebs-external-attacher-role",
                "resourceVersion": "5839",
                "uid": "e28c09a0-d5f9-430d-bf24-cf0533375ae1"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csinodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "ebs-external-provisioner-role",
                "resourceVersion": "5874",
                "uid": "6141d7d6-98d2-4fa4-ba7c-d744cbb715e9"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csinodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:05Z",
                "name": "ebs-external-resizer-role",
                "resourceVersion": "5966",
                "uid": "29f01c08-5e2c-4ca3-a917-1f2520a6e5b6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:06Z",
                "name": "ebs-external-snapshotter-role",
                "resourceVersion": "6015",
                "uid": "3aab9174-a84f-44e5-8b59-9d90dfedaa12"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "create",
                        "list",
                        "watch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list",
                        "delete",
                        "update",
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:07Z",
                "name": "ebs-kube-rbac-proxy-role",
                "resourceVersion": "6124",
                "uid": "b5482faa-8f6a-450e-b82f-f526f4d4c477"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "ebs-privileged-role",
                "resourceVersion": "5843",
                "uid": "e0429a59-b3f7-4af1-bd74-7e9b79befee5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "edit",
                "resourceVersion": "41133",
                "uid": "246e9fc8-dd1b-4552-87db-40238ddd4347"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "subscriptions"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy",
                        "secrets",
                        "services/proxy"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "events",
                        "persistentvolumeclaims",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "secrets",
                        "serviceaccounts",
                        "services",
                        "services/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "replicasets",
                        "replicasets/scale",
                        "statefulsets",
                        "statefulsets/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "ingresses",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete",
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate",
                        "buildconfigs/instantiatebinary",
                        "builds/clone"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "edit",
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigrollbacks",
                        "deploymentconfigs/instantiate",
                        "deploymentconfigs/rollback"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:08Z",
                "labels": {
                    "olm.owner": "global-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operators"
                },
                "name": "global-operators-admin",
                "resourceVersion": "6201",
                "uid": "0f7fd35d-332f-41aa-9c60-9368de44098a"
            },
            "rules": null
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "labels": {
                    "olm.owner": "global-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operators"
                },
                "name": "global-operators-edit",
                "resourceVersion": "6203",
                "uid": "a8462154-c4f7-405c-9f84-9316421172f0"
            },
            "rules": null
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "labels": {
                    "olm.owner": "global-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operators"
                },
                "name": "global-operators-view",
                "resourceVersion": "6207",
                "uid": "4259519d-8347-49ee-a337-d3562b0b90b5"
            },
            "rules": null
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "name": "grafana",
                "resourceVersion": "8343",
                "uid": "cf5da77e-0655-450e-9ecd-c2e623923019"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:51:09Z",
                "name": "helm-chartrepos-viewer",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "12062",
                "uid": "b5c18749-6657-4107-b732-c47349d640f2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "helm.openshift.io"
                    ],
                    "resources": [
                        "helmchartrepositories"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:35Z",
                "name": "insights-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1196",
                "uid": "f48aa9f7-7402-444d-9a7b-c8e118b19610"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "insights"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "get",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "insights"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:40Z",
                "name": "insights-operator-gather",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1300",
                "uid": "e02f7715-7a85-4577-a94d-e04ddb35076d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "imageregistry.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "imagepruners"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "proxy"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/log",
                        "nodes/metrics",
                        "nodes/proxy",
                        "nodes/stats"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machinesets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "installers.datahub.sap.com"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "controlplane.operator.openshift.io"
                    ],
                    "resources": [
                        "podnetworkconnectivitychecks"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "observability.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiserver.openshift.io"
                    ],
                    "resources": [
                        "apirequestcounts"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "jaegertracing.io"
                    ],
                    "resources": [
                        "jaegers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "costmanagement-metrics-cfg.openshift.io"
                    ],
                    "resources": [
                        "costmanagementmetricsconfig"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:42:12Z",
                "name": "kube-apiserver",
                "resourceVersion": "643",
                "uid": "e70e5a52-5775-4c6a-b711-26b4633673a8"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/proxy"
                    ],
                    "verbs": [
                        "get",
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "labels": {
                    "app.kubernetes.io/component": "exporter",
                    "app.kubernetes.io/name": "kube-state-metrics",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.2.3"
                },
                "name": "kube-state-metrics",
                "resourceVersion": "8344",
                "uid": "6e77fde3-abca-429a-b938-fba9777768f2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets",
                        "nodes",
                        "pods",
                        "services",
                        "resourcequotas",
                        "replicationcontrollers",
                        "limitranges",
                        "persistentvolumeclaims",
                        "persistentvolumes",
                        "namespaces",
                        "endpoints"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets",
                        "daemonsets",
                        "deployments",
                        "replicasets"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses",
                        "volumeattachments"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies",
                        "ingresses"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:15Z",
                "name": "machine-api-controllers",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2270",
                "uid": "4d9ea5f3-e47f-4fa9-b3df-4c42807e3f56"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/eviction"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "dnses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs",
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:16Z",
                "name": "machine-api-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2307",
                "uid": "8bdcc80a-d5b9-4c38-9753-d9cdf603e159"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "infrastructures/status"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "featuregates",
                        "featuregates/status",
                        "proxies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "watch",
                        "list",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations",
                        "mutatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "rbac.ext-remediation/aggregate-to-ext-remediation": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:17Z",
                "name": "machine-api-operator-ext-remediation",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2324",
                "uid": "f571d325-c8ef-4822-81d4-6a6aa5c171cb"
            },
            "rules": null
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:18Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "machine-api-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "2348",
                "uid": "af59db7e-6522-44f0-8cb0-5a0ecdf311f3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machinehealthchecks",
                        "machines",
                        "machinesets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:14Z",
                "name": "machine-config-controller",
                "resourceVersion": "6709",
                "uid": "26c6daaf-d525-441b-8e12-3a2ad243df7f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "clusterversions",
                        "featuregates"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "schedulers",
                        "apiservers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "imagecontentsourcepolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "etcds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:14Z",
                "name": "machine-config-controller-events",
                "resourceVersion": "6710",
                "uid": "4af0e326-d470-4abe-b95e-451c8969395c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:38Z",
                "name": "machine-config-daemon",
                "resourceVersion": "4039",
                "uid": "96ea22b1-ac40-4d3d-a290-135a0807d559"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/eviction"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:38Z",
                "name": "machine-config-daemon-events",
                "resourceVersion": "4040",
                "uid": "bf96faa5-7ea1-418a-a72d-99829ea46432"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:24Z",
                "name": "machine-config-server",
                "resourceVersion": "7125",
                "uid": "d97c06c4-0bed-4468-951b-72ba3c2bc71f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "machineconfigs",
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:33Z",
                "name": "marketplace-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1125",
                "uid": "a27818d5-e15b-4e14-8495-c28a10c9d46f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "operatorhubs",
                        "operatorhubs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "catalogsources",
                        "operatorsources"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "delete",
                        "update",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "services",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "subscriptions"
                    ],
                    "verbs": [
                        "get",
                        "update",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "metrics-daemon-role",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2625",
                "uid": "7b4aba85-cdad-4627-a0cb-60d841d2946f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "k8s.cni.cncf.io"
                    ],
                    "resources": [
                        "network-attachment-definitions"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:01Z",
                "name": "monitoring-edit",
                "resourceVersion": "8424",
                "uid": "e0947037-2e8f-407f-8a7e-c256bf5e589f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors",
                        "podmonitors",
                        "prometheusrules"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "name": "monitoring-rules-edit",
                "resourceVersion": "8361",
                "uid": "8b522c63-1393-4519-ac01-fb2ea4352be5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "prometheusrules"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:01Z",
                "name": "monitoring-rules-view",
                "resourceVersion": "8386",
                "uid": "84b649f9-85dd-49df-9b12-ca5cfe20759e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "prometheusrules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "multus",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2601",
                "uid": "2f6fd8c1-8349-472b-a63f-dcd82975b3d9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions",
                        "customresourcedefinitions/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "k8s.cni.cncf.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "pods/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "multus-admission-controller-webhook",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2694",
                "uid": "3f6c6e80-f868-464a-8b64-a4bdc99e65f9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:05Z",
                "name": "network-diagnostics",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2876",
                "uid": "fbf68324-dca9-436a-8317-4bb49a1bc2de"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "namespaces",
                        "pods",
                        "services",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "controlplane.operator.openshift.io"
                    ],
                    "resources": [
                        "podnetworkconnectivitychecks"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "controlplane.operator.openshift.io"
                    ],
                    "resources": [
                        "podnetworkconnectivitychecks/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "labels": {
                    "app.kubernetes.io/component": "exporter",
                    "app.kubernetes.io/name": "node-exporter",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "1.2.2"
                },
                "name": "node-exporter",
                "resourceVersion": "8352",
                "uid": "b6de4fe0-c1f0-4ae5-8689-75443f02e22d"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "node-exporter"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-admin": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "labels": {
                    "olm.owner": "olm-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operator-lifecycle-manager"
                },
                "name": "olm-operators-admin",
                "resourceVersion": "13430",
                "uid": "f228ffb8-b68a-4a8d-834c-19f1dac1213d"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-edit": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "labels": {
                    "olm.owner": "olm-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operator-lifecycle-manager"
                },
                "name": "olm-operators-edit",
                "resourceVersion": "13433",
                "uid": "15a2e66c-6c53-4254-a3f0-4962abf06dac"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-view": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:09Z",
                "labels": {
                    "olm.owner": "olm-operators",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-operator-lifecycle-manager"
                },
                "name": "olm-operators-view",
                "resourceVersion": "13438",
                "uid": "cfabe499-dd21-4fd6-b273-40b8c9c48e6a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-dde4314ecb73c236-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec91e8bc27c81ed7-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70eafa6e059987b5-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70f7b566ae4e6a1c-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cda6b569020ccb44-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-9d83214931a1a37e-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1dece667180a208d-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec80c7aff541a927-admin": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:08Z",
                "labels": {
                    "olm.owner": "openshift-cluster-monitoring",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-monitoring"
                },
                "name": "openshift-cluster-monitoring-admin",
                "resourceVersion": "174132",
                "uid": "0827ddd8-8004-4ad1-a1e3-e336bc1d9687"
            },
            "rules": null
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70f7b566ae4e6a1c-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cda6b569020ccb44-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-9d83214931a1a37e-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1dece667180a208d-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec80c7aff541a927-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-dde4314ecb73c236-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec91e8bc27c81ed7-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70eafa6e059987b5-edit": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:08Z",
                "labels": {
                    "olm.owner": "openshift-cluster-monitoring",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-monitoring"
                },
                "name": "openshift-cluster-monitoring-edit",
                "resourceVersion": "174133",
                "uid": "31ad2ede-39fc-4f7d-8a10-2a348c66a429"
            },
            "rules": null
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-dde4314ecb73c236-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec91e8bc27c81ed7-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70eafa6e059987b5-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-70f7b566ae4e6a1c-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cda6b569020ccb44-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-9d83214931a1a37e-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1dece667180a208d-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-ec80c7aff541a927-view": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:08Z",
                "labels": {
                    "olm.owner": "openshift-cluster-monitoring",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-monitoring"
                },
                "name": "openshift-cluster-monitoring-view",
                "resourceVersion": "174135",
                "uid": "1f96df5b-de1f-407d-b4d0-526de39e197b"
            },
            "rules": null
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-31b4d637926927c-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-d954f1473639740f-admin": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-admin": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:16Z",
                "labels": {
                    "olm.owner": "openshift-compliance-8nztr",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-compliance"
                },
                "name": "openshift-compliance-8nztr-admin",
                "resourceVersion": "174138",
                "uid": "7eefd433-f2d2-4355-9bc0-81d6be5cc008"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-31b4d637926927c-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-d954f1473639740f-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-edit": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-edit": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:16Z",
                "labels": {
                    "olm.owner": "openshift-compliance-8nztr",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-compliance"
                },
                "name": "openshift-compliance-8nztr-edit",
                "resourceVersion": "174139",
                "uid": "a236e996-eb98-4e88-9662-f9aabb1f1fba"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-31b4d637926927c-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-449ac30b34eb43de-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-daedf6ee5869a065-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-eab4bccdc604160a-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-cae8826e8ef698be-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-d954f1473639740f-view": "true"
                        }
                    },
                    {
                        "matchLabels": {
                            "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-view": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:16Z",
                "labels": {
                    "olm.owner": "openshift-compliance-8nztr",
                    "olm.owner.kind": "OperatorGroup",
                    "olm.owner.namespace": "openshift-compliance"
                },
                "name": "openshift-compliance-8nztr-view",
                "resourceVersion": "174137",
                "uid": "9c50c09c-41b3-41d3-820d-2d032e4b16f0"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:45Z",
                "name": "openshift-csi-snapshot-controller-runner",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1401",
                "uid": "4b996ee4-c475-4cc3-b1e2-fcad8af186ce"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:10Z",
                "name": "openshift-dns",
                "resourceVersion": "6445",
                "uid": "a608efb1-9e27-4a07-9684-3093748a0a5d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services",
                        "pods",
                        "namespaces"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:28Z",
                "name": "openshift-dns-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "942",
                "uid": "b83b5a0f-3e0d-40be-876e-b3ab3c8fc3cb"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "dnses"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "dnses/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces",
                        "services",
                        "serviceaccounts",
                        "configmaps",
                        "endpoints",
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles",
                        "clusterrolebindings",
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators",
                        "networks"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:28Z",
                "name": "openshift-ingress-operator",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "952",
                "uid": "e9d8afcd-0b51-4bd5-bf08-127b5f9808e6"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "namespaces",
                        "serviceaccounts",
                        "endpoints",
                        "services",
                        "secrets",
                        "pods",
                        "events"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments",
                        "daemonsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "servicemonitors"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles",
                        "clusterrolebindings",
                        "roles",
                        "rolebindings"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "ingresscontrollers",
                        "ingresscontrollers/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "ingress.operator.openshift.io"
                    ],
                    "resources": [
                        "dnsrecords",
                        "dnsrecords/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "ingresses",
                        "dnses",
                        "apiservers",
                        "networks"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "dnses",
                        "infrastructures",
                        "ingresses"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingressclasses"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routers/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "hostnetwork"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:56:17Z",
                "name": "openshift-ingress-router",
                "resourceVersion": "16998",
                "uid": "374aeda2-6c0c-4879-a595-acc55c97a31c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "namespaces",
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "hostnetwork"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "openshift-ovn-kubernetes-controller",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2728",
                "uid": "b07aed46-c02c-4952-af2c-5603019f341b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "watch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "k8s.ovn.org"
                    ],
                    "resources": [
                        "egressfirewalls",
                        "egressips"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "openshift-ovn-kubernetes-node",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2722",
                "uid": "63867581-7907-4a57-b5ea-211eaa213b8b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "namespaces",
                        "pods",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "k8s.ovn.org"
                    ],
                    "resources": [
                        "egressips"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "delete",
                        "update",
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "name": "openshift-state-metrics",
                "resourceVersion": "8345",
                "uid": "41f4cf07-0ac6-4ad0-bbf7-555b51e512f2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "builds"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "user.openshift.io"
                    ],
                    "resources": [
                        "groups"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:38Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "operatorhub-config-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1239",
                "uid": "4baaebd6-6d91-4dad-8abd-b7c6c5c068eb"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "operatorhubs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:53:43Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "packagemanifests-v1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiregistration.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "APIService",
                        "name": "v1.packages.operators.coreos.com",
                        "uid": "19bac172-4b8c-42c1-8d45-9870ca58a4b8"
                    }
                ],
                "resourceVersion": "13429",
                "uid": "70a1da57-a9a4-4dbd-a478-59eaf9fee0b4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:53:43Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "packagemanifests-v1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiregistration.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "APIService",
                        "name": "v1.packages.operators.coreos.com",
                        "uid": "19bac172-4b8c-42c1-8d45-9870ca58a4b8"
                    }
                ],
                "resourceVersion": "13432",
                "uid": "dee3284f-8b26-4823-9bc2-238f7f5caf41"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:53:44Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-4bca9f23e412d79d-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "packagemanifests-v1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiregistration.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "APIService",
                        "name": "v1.packages.operators.coreos.com",
                        "uid": "19bac172-4b8c-42c1-8d45-9870ca58a4b8"
                    }
                ],
                "resourceVersion": "13436",
                "uid": "db755411-13d0-45c0-9461-3fe7f18ef0e3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:53:39Z",
                "name": "pod-identity-webhook",
                "resourceVersion": "13308",
                "uid": "945e7349-f3f1-4f00-b5c0-193c99958229"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "profilebundles.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profilebundles.compliance.openshift.io",
                        "uid": "9a5aff1a-9703-49d5-9a4b-940c91319a97"
                    }
                ],
                "resourceVersion": "40999",
                "uid": "eb2e51af-a662-40db-a764-a32958910085"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "profilebundles.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profilebundles.compliance.openshift.io",
                        "uid": "9a5aff1a-9703-49d5-9a4b-940c91319a97"
                    }
                ],
                "resourceVersion": "41002",
                "uid": "ead231ee-7506-4e51-a4fa-af5c79c908b2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "profilebundles.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profilebundles.compliance.openshift.io",
                        "uid": "9a5aff1a-9703-49d5-9a4b-940c91319a97"
                    }
                ],
                "resourceVersion": "40988",
                "uid": "b2291824-180e-4345-a532-69d86a9629cf"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-880fc96b1ae8ad9d-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "profilebundles.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profilebundles.compliance.openshift.io",
                        "uid": "9a5aff1a-9703-49d5-9a4b-940c91319a97"
                    }
                ],
                "resourceVersion": "40993",
                "uid": "b61c78e5-31fa-48eb-a024-4c9c8145d6bd"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "profiles.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profiles.compliance.openshift.io",
                        "uid": "ca35e8e3-28b6-41f0-8f72-2572ccacfe43"
                    }
                ],
                "resourceVersion": "41013",
                "uid": "a339eb8f-ffd2-4fb1-ba8d-3d40fabb3a67"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "profiles.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profiles.compliance.openshift.io",
                        "uid": "ca35e8e3-28b6-41f0-8f72-2572ccacfe43"
                    }
                ],
                "resourceVersion": "41021",
                "uid": "e351e587-cafd-4c67-a2b9-2740055bd703"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "profiles.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profiles.compliance.openshift.io",
                        "uid": "ca35e8e3-28b6-41f0-8f72-2572ccacfe43"
                    }
                ],
                "resourceVersion": "41017",
                "uid": "49b201c3-1e9c-4bf5-bd98-1b51ad4a3143"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-8961166d10dc0efd-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "profiles.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "profiles.compliance.openshift.io",
                        "uid": "ca35e8e3-28b6-41f0-8f72-2572ccacfe43"
                    }
                ],
                "resourceVersion": "41007",
                "uid": "10bbdbbf-c819-4251-8e3b-94d61449578d"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "labels": {
                    "app.kubernetes.io/component": "metrics-adapter",
                    "app.kubernetes.io/name": "prometheus-adapter",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.9.0"
                },
                "name": "prometheus-adapter",
                "resourceVersion": "8327",
                "uid": "0d8e0702-e65d-4c73-895f-2d0386a12b8d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes",
                        "namespaces",
                        "pods",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "prometheus",
                    "app.kubernetes.io/name": "prometheus",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "2.30.3"
                },
                "name": "prometheus-k8s",
                "resourceVersion": "20000",
                "uid": "fdb98619-904b-4516-9c09-f9ffbd33789e"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:56Z",
                "name": "prometheus-k8s-scheduler-resources",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1683",
                "uid": "3a158093-1055-41d6-a5d1-c2d414732c17"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/metrics/resources"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:48Z",
                "labels": {
                    "app.kubernetes.io/component": "controller",
                    "app.kubernetes.io/name": "prometheus-operator",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.51.2"
                },
                "name": "prometheus-operator",
                "resourceVersion": "7890",
                "uid": "8ea92ce8-e8da-4ad0-98ca-090f6e75a6e9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "monitoring.coreos.com"
                    ],
                    "resources": [
                        "alertmanagers",
                        "alertmanagers/finalizers",
                        "alertmanagerconfigs",
                        "prometheuses",
                        "prometheuses/finalizers",
                        "thanosrulers",
                        "thanosrulers/finalizers",
                        "servicemonitors",
                        "podmonitors",
                        "probes",
                        "prometheusrules"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services",
                        "services/finalizers",
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "update",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "registry-admin",
                "resourceVersion": "9624",
                "uid": "a19b7df6-24aa-4f41-82d9-662c39fb54a9"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "delete",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "resourceaccessreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "registry-editor",
                "resourceVersion": "9626",
                "uid": "86a27534-ba2c-4fef-89a6-d397cd4f93c4"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:26Z",
                "name": "registry-monitoring",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "786",
                "uid": "fea0ad28-32af-4445-b13d-f31a5fa051ac"
            },
            "rules": [
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "registry/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "registry-viewer",
                "resourceVersion": "9631",
                "uid": "949b8b44-5d12-40cb-8008-afd7d4723394"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "labels": {
                    "app.kubernetes.io/component": "metrics-adapter",
                    "app.kubernetes.io/name": "prometheus-adapter",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.9.0"
                },
                "name": "resource-metrics-server-resources",
                "resourceVersion": "8350",
                "uid": "184b68a2-52d0-464c-b4c7-45f58e25d59f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:56:18Z",
                "name": "router-monitoring",
                "resourceVersion": "17090",
                "uid": "becc9363-a77c-4846-9556-c45e1d19015f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routers/metrics"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "rules.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "rules.compliance.openshift.io",
                        "uid": "2049e0cc-ce57-4f56-a50b-539342cac1ab"
                    }
                ],
                "resourceVersion": "41027",
                "uid": "41cf4def-a561-49c8-80d8-44134202133b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "rules.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "rules.compliance.openshift.io",
                        "uid": "2049e0cc-ce57-4f56-a50b-539342cac1ab"
                    }
                ],
                "resourceVersion": "41044",
                "uid": "07d8c809-b7e2-475d-abf1-17b4e463d635"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "rules.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "rules.compliance.openshift.io",
                        "uid": "2049e0cc-ce57-4f56-a50b-539342cac1ab"
                    }
                ],
                "resourceVersion": "41033",
                "uid": "8cd3dc83-63d2-4ae2-a7b6-c799a4605749"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:56Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-687c325f435ba8ce-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "rules.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "rules.compliance.openshift.io",
                        "uid": "2049e0cc-ce57-4f56-a50b-539342cac1ab"
                    }
                ],
                "resourceVersion": "41038",
                "uid": "a3bec58c-e19c-44ab-952b-30dc5fcd55d8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-31b4d637926927c-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "scansettingbindings.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettingbindings.compliance.openshift.io",
                        "uid": "a8418e68-2014-44e0-a088-a821389853a7"
                    }
                ],
                "resourceVersion": "41050",
                "uid": "4fc8a469-b95e-4179-8b6e-2a966b8662ac"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-31b4d637926927c-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "scansettingbindings.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettingbindings.compliance.openshift.io",
                        "uid": "a8418e68-2014-44e0-a088-a821389853a7"
                    }
                ],
                "resourceVersion": "41065",
                "uid": "72d6eb09-39fe-46a1-88b9-fe25d0f41aa0"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-31b4d637926927c-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "scansettingbindings.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettingbindings.compliance.openshift.io",
                        "uid": "a8418e68-2014-44e0-a088-a821389853a7"
                    }
                ],
                "resourceVersion": "41053",
                "uid": "f305db62-d89e-4151-9410-a730c1069972"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-31b4d637926927c-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "scansettingbindings.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettingbindings.compliance.openshift.io",
                        "uid": "a8418e68-2014-44e0-a088-a821389853a7"
                    }
                ],
                "resourceVersion": "41059",
                "uid": "7e4bda2d-c20a-473a-bfcd-bfa647e8512a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "scansettings.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettings.compliance.openshift.io",
                        "uid": "3532256e-b3f5-4977-8ec1-276395ac402c"
                    }
                ],
                "resourceVersion": "41072",
                "uid": "2a5ed159-69ee-4f86-bb8c-2abf1207a9a4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "scansettings.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettings.compliance.openshift.io",
                        "uid": "3532256e-b3f5-4977-8ec1-276395ac402c"
                    }
                ],
                "resourceVersion": "41085",
                "uid": "65164b15-7911-49ee-a447-96c7688c3f62"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "scansettings.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettings.compliance.openshift.io",
                        "uid": "3532256e-b3f5-4977-8ec1-276395ac402c"
                    }
                ],
                "resourceVersion": "41075",
                "uid": "4826b785-cab7-4f00-9792-8eac25f34ef3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-22ce358a50843a97-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "scansettings.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "scansettings.compliance.openshift.io",
                        "uid": "3532256e-b3f5-4977-8ec1-276395ac402c"
                    }
                ],
                "resourceVersion": "41080",
                "uid": "85126d3c-4fcd-44a5-8919-3f9ade9bad4c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "self-access-reviewer",
                "resourceVersion": "9597",
                "uid": "1655078d-d23f-4c0c-a317-8cf8087e69db"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "selfsubjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "selfsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "A user that can request projects.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "self-provisioner",
                "resourceVersion": "9599",
                "uid": "f89988eb-9ee3-437a-afd7-adad8430d0b5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "storage.openshift.io/aggregate-to-storage-admin": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "storage-admin",
                "resourceVersion": "9576",
                "uid": "1606ab46-f3b1-49ad-b860-e89e2b186b4c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses",
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete",
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events",
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "sudoer",
                "resourceVersion": "9562",
                "uid": "63adceed-6a1a-4e38-930c-241efd27e1d0"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resourceNames": [
                        "system:admin"
                    ],
                    "resources": [
                        "systemusers",
                        "users"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resourceNames": [
                        "system:masters"
                    ],
                    "resources": [
                        "groups",
                        "systemgroups"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "system:aggregate-to-admin",
                "resourceVersion": "107",
                "uid": "36ddc821-61db-44f3-a550-10ce858770e4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "system:aggregate-to-edit",
                "resourceVersion": "108",
                "uid": "09a25e8a-e086-4738-bded-ed257ad1c256"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy",
                        "secrets",
                        "services/proxy"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "pods/attach",
                        "pods/exec",
                        "pods/portforward",
                        "pods/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "events",
                        "persistentvolumeclaims",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "secrets",
                        "serviceaccounts",
                        "services",
                        "services/proxy"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "replicasets",
                        "replicasets/scale",
                        "statefulsets",
                        "statefulsets/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "jobs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "deployments",
                        "deployments/rollback",
                        "deployments/scale",
                        "ingresses",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "system:aggregate-to-view",
                "resourceVersion": "109",
                "uid": "5ca3fe7b-17f2-48a4-8dc0-d7eaa66a0b61"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "labels": {
                    "app.kubernetes.io/component": "metrics-adapter",
                    "app.kubernetes.io/name": "prometheus-adapter",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.9.0",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "system:aggregated-metrics-reader",
                "resourceVersion": "8359",
                "uid": "0a3542f3-4095-44d5-b96c-b6754b99d8f7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:auth-delegator",
                "resourceVersion": "115",
                "uid": "a72948fb-5cf5-4657-af13-6d8e43ffea23"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:basic-user",
                "resourceVersion": "102",
                "uid": "19054406-b74b-4232-b18b-2f4e31976206"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "selfsubjectaccessreviews",
                        "selfsubjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:build-strategy-custom",
                "resourceVersion": "9570",
                "uid": "3df675ff-1f65-49df-b48b-0099d294aeef"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/custom"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:build-strategy-docker",
                "resourceVersion": "9569",
                "uid": "08f25234-7e26-47da-be75-6fd4294e489e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/docker",
                        "builds/optimizeddocker"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:build-strategy-jenkinspipeline",
                "resourceVersion": "9572",
                "uid": "5cc2c901-4c9a-4655-b5e2-64bbfb845e56"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/jenkinspipeline"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:build-strategy-source",
                "resourceVersion": "9571",
                "uid": "af95fbd5-e855-41f7-a93c-186010c4a918"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/source"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:certificatesigningrequests:nodeclient",
                "resourceVersion": "120",
                "uid": "b222262a-e7fa-41d2-8781-eac745337527"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/nodeclient"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:certificatesigningrequests:selfnodeclient",
                "resourceVersion": "121",
                "uid": "b438d827-a8e9-452c-8c59-e27107416a79"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/selfnodeclient"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:kube-apiserver-client-approver",
                "resourceVersion": "125",
                "uid": "2db609a2-c15f-4e7a-ad2b-9d6dcf23228e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:kube-apiserver-client-kubelet-approver",
                "resourceVersion": "126",
                "uid": "b33f893b-4db0-4a53-811f-3d7282634a50"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client-kubelet"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:kubelet-serving-approver",
                "resourceVersion": "124",
                "uid": "83948e72-d32e-4aeb-b3e4-dad9bf559ad1"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kubelet-serving"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:certificates.k8s.io:legacy-unknown-approver",
                "resourceVersion": "123",
                "uid": "fc01d349-6bad-4c98-97c5-6a1e99ef0467"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/legacy-unknown"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:attachdetach-controller",
                "resourceVersion": "132",
                "uid": "27d59357-0798-47ff-84a0-6925bdbdc0ac"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims",
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csinodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:certificate-controller",
                "resourceVersion": "158",
                "uid": "c667c6b2-a056-42bf-9372-d8998eda7283"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/approval",
                        "certificatesigningrequests/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client-kubelet"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client",
                        "kubernetes.io/kube-apiserver-client-kubelet",
                        "kubernetes.io/kubelet-serving",
                        "kubernetes.io/legacy-unknown"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "sign"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:clusterrole-aggregation-controller",
                "resourceVersion": "133",
                "uid": "7fc3ec23-3e0d-45ce-983b-d54e25c3df30"
            },
            "rules": [
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "escalate",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:cronjob-controller",
                "resourceVersion": "134",
                "uid": "3ef6b741-b95c-42de-a4b8-64ef72a6af95"
            },
            "rules": [
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "delete",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:daemon-set-controller",
                "resourceVersion": "135",
                "uid": "d540851d-17ec-4f2c-a1df-a1d650c40208"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/binding"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:deployment-controller",
                "resourceVersion": "136",
                "uid": "ec01bb49-b54b-459c-b06a-3f2ac46b2d93"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:disruption-controller",
                "resourceVersion": "137",
                "uid": "0d37f58d-d634-4cf3-ba58-8dc30c66190b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*/scale"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:endpoint-controller",
                "resourceVersion": "138",
                "uid": "33863cd5-5ebd-4472-9803-ced3f9aa0d60"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints/restricted"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:endpointslice-controller",
                "resourceVersion": "139",
                "uid": "4833deab-2dde-4f0a-b4ab-ffd4344cf6db"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes",
                        "pods",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices/restricted"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:endpointslicemirroring-controller",
                "resourceVersion": "140",
                "uid": "b1af470a-4ad3-44a5-940e-5bfa18624e83"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices/restricted"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:ephemeral-volume-controller",
                "resourceVersion": "142",
                "uid": "21aee365-0192-466a-be04-ce6986f22410"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:expand-controller",
                "resourceVersion": "141",
                "uid": "c97b79bc-b2d1-4cbc-a334-1bbfc2bfaa4c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:generic-garbage-collector",
                "resourceVersion": "143",
                "uid": "505684e2-53c0-43e4-b018-ae0999b0d2c4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:horizontal-pod-autoscaler",
                "resourceVersion": "144",
                "uid": "b874cce8-e6c1-48ff-8b86-0ae0da8efbd5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "http:heapster:",
                        "https:heapster:"
                    ],
                    "resources": [
                        "services/proxy"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "custom.metrics.k8s.io"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:job-controller",
                "resourceVersion": "145",
                "uid": "29ac7bec-18a3-4dc0-8bfc-2680844b336b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:namespace-controller",
                "resourceVersion": "146",
                "uid": "c779839f-2cf3-4b70-bb2a-979322c9cc1f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces/finalize",
                        "namespaces/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "delete",
                        "deletecollection",
                        "get",
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:node-controller",
                "resourceVersion": "147",
                "uid": "7fb37add-bf50-41d4-8717-26158e949002"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "delete",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:06Z",
                "name": "system:controller:operator-lifecycle-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1977",
                "uid": "f2ba1501-2892-41f8-a013-8c1adceab1cb"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:persistent-volume-binder",
                "resourceVersion": "148",
                "uid": "5c196e31-661a-4a7b-bd1f-aea6bbd17ba3"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:pod-garbage-collector",
                "resourceVersion": "149",
                "uid": "423eccb3-aba6-444b-92e1-cb177fcd6738"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "delete",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:pv-protection-controller",
                "resourceVersion": "160",
                "uid": "6373be99-4adc-4b39-b923-1d8f48f9fcbe"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:pvc-protection-controller",
                "resourceVersion": "159",
                "uid": "a050cabd-7b55-424a-bc4d-37403c0fe39d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:replicaset-controller",
                "resourceVersion": "150",
                "uid": "1a3c1209-d89b-40bc-a818-7869e847ee50"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:replication-controller",
                "resourceVersion": "151",
                "uid": "04394ae7-049f-4185-b3dd-70bfd9aa75a2"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:resourcequota-controller",
                "resourceVersion": "152",
                "uid": "2d236417-1f42-4e68-aeb3-bf128abe7518"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:root-ca-cert-publisher",
                "resourceVersion": "162",
                "uid": "751e8316-8104-4758-be9d-98767158635d"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:route-controller",
                "resourceVersion": "153",
                "uid": "80d9dbb9-fe65-4e56-a30e-7a7ae106e511"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:service-account-controller",
                "resourceVersion": "154",
                "uid": "6f99d1d4-7029-48dc-b1b2-6c46a5371767"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:service-ca-cert-publisher",
                "resourceVersion": "163",
                "uid": "5f7d82e3-4902-4373-bf7c-39fcf959fb99"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:service-controller",
                "resourceVersion": "155",
                "uid": "70c0efa4-2d9c-4423-939d-d7d3fdcee506"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:statefulset-controller",
                "resourceVersion": "156",
                "uid": "68ad3b8a-3386-4e69-9d52-91ac2d2fb75b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:ttl-after-finished-controller",
                "resourceVersion": "161",
                "uid": "ccf9afe8-b38b-4abd-a4e1-fd6029969d8e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:controller:ttl-controller",
                "resourceVersion": "157",
                "uid": "5d04bf9e-cf88-4761-a316-63ec874a657b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Grants the right to deploy within a project.  Used primarily with service accounts for automated deployments.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:deployer",
                "resourceVersion": "9610",
                "uid": "d586cc1d-ca82-4671-8561-4d0316ad8528"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/log"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:discovery",
                "resourceVersion": "99",
                "uid": "334397c9-29d1-4dcf-9010-92134c682f03"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/api",
                        "/api/*",
                        "/apis",
                        "/apis/*",
                        "/healthz",
                        "/livez",
                        "/openapi",
                        "/openapi/*",
                        "/readyz",
                        "/version",
                        "/version/"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:heapster",
                "resourceVersion": "110",
                "uid": "b9fadd06-7891-40e6-9bfc-83809fb6e0d9"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events",
                        "namespaces",
                        "nodes",
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:image-auditor",
                "resourceVersion": "9601",
                "uid": "9dee237c-ca8c-46e7-b33a-73abfb14c410"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Grants the right to build, push and pull images from within a project.  Used primarily with service accounts for builds.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "system:image-builder",
                "resourceVersion": "9604",
                "uid": "eda7a6b6-22ee-4146-851e-e7d32ea85928"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:image-pruner",
                "resourceVersion": "9605",
                "uid": "c84b6ad2-113e-4df2-a409-3bda1355331b"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "limitranges"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "jobs"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "imagestreams"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Grants the right to pull images from within a project.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:image-puller",
                "resourceVersion": "9602",
                "uid": "72a48aff-fdf0-47f8-be9a-7e5082515eab"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "openshift.io/description": "Grants the right to push and pull images from within a project.",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:image-pusher",
                "resourceVersion": "9603",
                "uid": "8849e8f6-f53e-4a56-b82a-7bbb9993c51c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:image-signer",
                "resourceVersion": "9608",
                "uid": "85a4c29f-7d16-40e2-876f-a8136e015c0b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagesignatures"
                    ],
                    "verbs": [
                        "create",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:kube-aggregator",
                "resourceVersion": "116",
                "uid": "1aba1f0b-6de1-4564-aaa5-d46da26e1670"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:kube-controller-manager",
                "resourceVersion": "117",
                "uid": "3c16e986-e076-40a9-8b51-e50e53cf85c7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resourceNames": [
                        "kube-controller-manager"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "kube-controller-manager"
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "namespaces",
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts/token"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:kube-dns",
                "resourceVersion": "118",
                "uid": "f05c4cf9-759e-4469-9179-2ee3def68797"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:kube-scheduler",
                "resourceVersion": "129",
                "uid": "b756fe67-c5df-4efa-bebc-a95508bd116c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resourceNames": [
                        "kube-scheduler"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resourceNames": [
                        "kube-scheduler"
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "pods/binding"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "replicasets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims",
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csinodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csistoragecapacities"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:kubelet-api-admin",
                "resourceVersion": "113",
                "uid": "e3d4d4df-aa9e-460e-affe-9b6e706c7f21"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "proxy"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/log",
                        "nodes/metrics",
                        "nodes/proxy",
                        "nodes/spec",
                        "nodes/stats"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:master",
                "resourceVersion": "9613",
                "uid": "7f27ca7b-eeb4-4ea7-a96b-c74249299031"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:monitoring",
                "resourceVersion": "100",
                "uid": "5ea9a3ba-3487-4bd6-87b6-b0c9de6aea67"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/healthz",
                        "/healthz/*",
                        "/livez",
                        "/livez/*",
                        "/metrics",
                        "/readyz",
                        "/readyz/*"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node",
                "resourceVersion": "111",
                "uid": "65017541-b434-48be-a393-0ea522d8c879"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods/eviction"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims",
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "volumeattachments"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts/token"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csinodes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "node.k8s.io"
                    ],
                    "resources": [
                        "runtimeclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node-admin",
                "resourceVersion": "130",
                "uid": "ee06b1f4-6ea5-4c19-93fc-2ed1c9d0f63a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "proxy"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/log",
                        "nodes/metrics",
                        "nodes/proxy",
                        "nodes/spec",
                        "nodes/stats"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node-bootstrapper",
                "resourceVersion": "114",
                "uid": "322f5b31-03dd-4558-a76b-972dd0d27891"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node-problem-detector",
                "resourceVersion": "112",
                "uid": "a33d67d1-19dd-4139-8c22-3b0305cfe55f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/status"
                    ],
                    "verbs": [
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node-proxier",
                "resourceVersion": "128",
                "uid": "bd420acb-b9b4-451d-bd5a-50aeede90a54"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:node-reader",
                "resourceVersion": "131",
                "uid": "a9271ca6-e0b1-4cc3-8bf0-d346c7e5c546"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics",
                        "nodes/spec"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/stats"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:oauth-token-deleter",
                "resourceVersion": "9615",
                "uid": "7e6db53e-b83f-425c-8955-d6e990c9d821"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "oauth.openshift.io"
                    ],
                    "resources": [
                        "oauthaccesstokens",
                        "oauthauthorizetokens"
                    ],
                    "verbs": [
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:56Z",
                "labels": {
                    "addonmanager.kubernetes.io/mode": "Reconcile",
                    "kubernetes.io/cluster-service": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "system:openshift:aggregate-snapshots-to-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1686",
                "uid": "ae49c8f8-0970-43da-a5b1-336b878bdd4f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete",
                        "deletecollection"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:59Z",
                "labels": {
                    "addonmanager.kubernetes.io/mode": "Reconcile",
                    "authorization.openshift.io/aggregate-to-basic-user": "true",
                    "kubernetes.io/cluster-service": "true"
                },
                "name": "system:openshift:aggregate-snapshots-to-basic-user",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1793",
                "uid": "7022ae15-11b6-4d2d-a65a-02d2ed5ebe6a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:02Z",
                "labels": {
                    "addonmanager.kubernetes.io/mode": "Reconcile",
                    "kubernetes.io/cluster-service": "true",
                    "storage.openshift.io/aggregate-to-storage-admin": "true"
                },
                "name": "system:openshift:aggregate-snapshots-to-storage-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1839",
                "uid": "2bcffbce-9005-499b-a146-04aed7775148"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshotclasses",
                        "volumesnapshotcontents"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete",
                        "deletecollection"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:57Z",
                "labels": {
                    "addonmanager.kubernetes.io/mode": "Reconcile",
                    "kubernetes.io/cluster-service": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "system:openshift:aggregate-snapshots-to-view",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1752",
                "uid": "13852765-0333-4d7e-87a8-53b5ecd75f1f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "system:openshift:aggregate-to-admin",
                "resourceVersion": "9578",
                "uid": "090db705-259c-4fbe-9914-e8ad037c80e3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicyreviews",
                        "podsecuritypolicyselfsubjectreviews",
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "rolebindingrestrictions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate",
                        "buildconfigs/instantiatebinary",
                        "builds/clone"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "admin",
                        "edit",
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigrollbacks",
                        "deploymentconfigs/instantiate",
                        "deploymentconfigs/rollback"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "resourceaccessreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "authorization.openshift.io/aggregate-to-basic-user": "true"
                },
                "name": "system:openshift:aggregate-to-basic-user",
                "resourceVersion": "9594",
                "uid": "731c9ea3-928a-4268-8860-32893df36ad9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resourceNames": [
                        "~"
                    ],
                    "resources": [
                        "users"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterroles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "selfsubjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "selfsubjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "system:openshift:aggregate-to-cluster-reader",
                "resourceVersion": "9566",
                "uid": "7529cff4-af3d-4388-ac61-c879f50942a0"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "componentstatuses",
                        "nodes",
                        "nodes/status",
                        "persistentvolumeclaims/status",
                        "persistentvolumes",
                        "persistentvolumes/status",
                        "pods/binding",
                        "pods/eviction",
                        "podtemplates",
                        "securitycontextconstraints",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets/status",
                        "deployments/status",
                        "replicasets/status",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions",
                        "customresourcedefinitions/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiregistration.k8s.io"
                    ],
                    "resources": [
                        "apiservices",
                        "apiservices/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs/status",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "coordination.k8s.io"
                    ],
                    "resources": [
                        "leases"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "node.k8s.io"
                    ],
                    "resources": [
                        "runtimeclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets/status",
                        "podsecuritypolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "csidrivers",
                        "csinodes",
                        "storageclasses",
                        "volumeattachments",
                        "volumeattachments/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "scheduling.k8s.io"
                    ],
                    "resources": [
                        "priorityclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests",
                        "certificatesigningrequests/approval",
                        "certificatesigningrequests/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "clusterrolebindings",
                        "clusterroles",
                        "rolebindingrestrictions",
                        "rolebindings",
                        "roles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images",
                        "imagesignatures"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "oauth.openshift.io"
                    ],
                    "resources": [
                        "oauthclientauthorizations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projectrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas",
                        "clusterresourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "clusternetworks",
                        "egressnetworkpolicies",
                        "hostsubnets",
                        "netnamespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resources": [
                        "rangeallocations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "brokertemplateinstances",
                        "templateinstances/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "user.openshift.io"
                    ],
                    "resources": [
                        "groups",
                        "identities",
                        "useridentitymappings",
                        "users"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "localresourceaccessreviews",
                        "localsubjectaccessreviews",
                        "resourceaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews",
                        "subjectrulesreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "localsubjectaccessreviews",
                        "selfsubjectaccessreviews",
                        "selfsubjectrulesreviews",
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicyreviews",
                        "podsecuritypolicyselfsubjectreviews",
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/metrics",
                        "nodes/spec"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes/stats"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "nonResourceURLs": [
                        "*"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "system:openshift:aggregate-to-edit",
                "resourceVersion": "9580",
                "uid": "51fac3b1-f824-4e08-b985-48b75027f557"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate",
                        "buildconfigs/instantiatebinary",
                        "builds/clone"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/details"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "edit",
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigrollbacks",
                        "deploymentconfigs/instantiate",
                        "deploymentconfigs/rollback"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreams/secrets",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "storage.openshift.io/aggregate-to-storage-admin": "true"
                },
                "name": "system:openshift:aggregate-to-storage-admin",
                "resourceVersion": "9575",
                "uid": "ab859910-55cb-4a08-8835-cf128f24edef"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "deletecollection",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events",
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "system:openshift:aggregate-to-view",
                "resourceVersion": "9584",
                "uid": "aadafa37-f678-4344-be2e-d3b3efa81922"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:28Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "system:openshift:cloud-credential-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "853",
                "uid": "00d05daf-edb8-4624-8270-82bef40973c4"
            },
            "rules": [
                {
                    "apiGroups": [
                        "cloudcredential.openshift.io"
                    ],
                    "resources": [
                        "credentialsrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:03Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "system:openshift:cluster-config-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1875",
                "uid": "f508b74c-a220-450b-83a6-6798eb309fc8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "apiservers",
                        "authentications",
                        "builds",
                        "clusteroperators",
                        "clusterversions",
                        "consoles",
                        "dnses",
                        "featuregates",
                        "images",
                        "infrastructures",
                        "ingresses",
                        "networks",
                        "oauths",
                        "projects",
                        "proxies",
                        "schedulers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:02Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "system:openshift:cluster-samples-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1838",
                "uid": "2f8233b9-603f-4084-b877-6a6097c73c1a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "samples.operator.openshift.io"
                    ],
                    "resources": [
                        "configs",
                        "configs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:build-config-change-controller",
                "resourceVersion": "9639",
                "uid": "9ba7c33d-fcf2-4fae-ba74-f3099c7c59e1"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:build-controller",
                "resourceVersion": "9638",
                "uid": "3727e568-8fc1-44c9-ab3d-b8be07973254"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/custom",
                        "builds/docker",
                        "builds/jenkinspipeline",
                        "builds/optimizeddocker",
                        "builds/source"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "security.openshift.io"
                    ],
                    "resources": [
                        "podsecuritypolicysubjectreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "system:openshift:controller:check-endpoints",
                "resourceVersion": "5877",
                "uid": "98c67ba9-b8a4-4f43-8cd0-a15c6f9896e9"
            },
            "rules": [
                {
                    "apiGroups": [
                        "controlplane.operator.openshift.io"
                    ],
                    "resources": [
                        "podnetworkconnectivitychecks"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "controlplane.operator.openshift.io"
                    ],
                    "resources": [
                        "podnetworkconnectivitychecks/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods",
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "system:openshift:controller:check-endpoints-crd-reader",
                "resourceVersion": "5879",
                "uid": "16f7fbe7-015b-48ae-a16f-de2bf862a40c"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:04Z",
                "name": "system:openshift:controller:check-endpoints-node-reader",
                "resourceVersion": "5878",
                "uid": "b15565b5-7644-4fdd-8dfe-6ae515ebb0de"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:47:02Z",
                "name": "system:openshift:controller:cluster-csr-approver-controller",
                "resourceVersion": "5670",
                "uid": "94eacdef-26dd-4b7b-8822-7e96f59b56a2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/approval"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:cluster-quota-reconciliation-controller",
                "resourceVersion": "9657",
                "uid": "5f2ee52d-0957-48c6-bc9d-db3fb7ee1e5f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "clusterresourcequotas/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:default-rolebindings-controller",
                "resourceVersion": "9664",
                "uid": "fbb826f6-9d19-4557-bd5f-6c836a2fa9be"
            },
            "rules": [
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "rolebindings"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "rbac.authorization.k8s.io"
                    ],
                    "resources": [
                        "rolebindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:deployer-controller",
                "resourceVersion": "9641",
                "uid": "6c1f56ff-b8f4-42ae-a075-7de538ed598c"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:deploymentconfig-controller",
                "resourceVersion": "9643",
                "uid": "7e82d4a4-7672-492e-b764-2cb67be6767f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:horizontal-pod-autoscaler",
                "resourceVersion": "9662",
                "uid": "78b1ca8d-558e-42f8-ac69-0fb5a4d18016"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:image-import-controller",
                "resourceVersion": "9656",
                "uid": "9deba55e-3e51-462f-9bd8-0d2ddc216742"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimports"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:image-trigger-controller",
                "resourceVersion": "9653",
                "uid": "ca361508-e581-4281-a8e3-0c1520a04553"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "statefulsets"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/instantiate"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/custom",
                        "builds/docker",
                        "builds/jenkinspipeline",
                        "builds/optimizeddocker",
                        "builds/source"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:43:04Z",
                "name": "system:openshift:controller:machine-approver",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1907",
                "uid": "8f78889a-6663-43ea-ace8-7054c8db18d7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resources": [
                        "certificatesigningrequests/approval"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "certificates.k8s.io"
                    ],
                    "resourceNames": [
                        "kubernetes.io/kube-apiserver-client-kubelet",
                        "kubernetes.io/kubelet-serving"
                    ],
                    "resources": [
                        "signers"
                    ],
                    "verbs": [
                        "approve"
                    ]
                },
                {
                    "apiGroups": [
                        "machine.openshift.io"
                    ],
                    "resources": [
                        "machines"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "watch",
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "machine-approver"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "networks"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "network.openshift.io"
                    ],
                    "resources": [
                        "hostsubnets"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:55Z",
                "name": "system:openshift:controller:namespace-security-allocation-controller",
                "resourceVersion": "488",
                "uid": "f18a6352-8ea6-4c81-9d25-98c3ff0c8d91"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io",
                        "security.internal.openshift.io"
                    ],
                    "resources": [
                        "rangeallocations"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:origin-namespace-controller",
                "resourceVersion": "9649",
                "uid": "b92c1d1f-873f-4cc8-939d-3344cd432a38"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces/finalize",
                        "namespaces/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:pv-recycler-controller",
                "resourceVersion": "9660",
                "uid": "222776d0-7b6e-4f1c-9e98-33a07da4f376"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:resourcequota-controller",
                "resourceVersion": "9661",
                "uid": "0b857744-d039-43a1-b92c-483586e82f4a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotas"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:controller:service-ca",
                "resourceVersion": "4593",
                "uid": "1f530cc3-b3ce-4e3e-8f1a-dc8e7c069dff"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        "admissionregistration.k8s.io"
                    ],
                    "resources": [
                        "mutatingwebhookconfigurations",
                        "validatingwebhookconfigurations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apiregistration.k8s.io"
                    ],
                    "resources": [
                        "apiservices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update",
                        "patch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:service-ingress-ip-controller",
                "resourceVersion": "9659",
                "uid": "59dc375f-d36a-4ee6-adf8-fe2a0e49fe94"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:service-serving-cert-controller",
                "resourceVersion": "9655",
                "uid": "99943f44-8ff6-41e5-8c13-d5549a250a0f"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:serviceaccount-controller",
                "resourceVersion": "9650",
                "uid": "3abd7f35-5663-4d04-acf7-72809bfab998"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:serviceaccount-pull-secrets-controller",
                "resourceVersion": "9652",
                "uid": "07ab6971-c95d-420c-96c7-99b5d30e09dd"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "serviceaccounts"
                    ],
                    "verbs": [
                        "create",
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:template-instance-controller",
                "resourceVersion": "9646",
                "uid": "8729cb0d-f781-4c01-9eab-72c118e802ca"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "templateinstances/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:template-instance-finalizer-controller",
                "resourceVersion": "9648",
                "uid": "38953237-e1d4-4f5e-9d9f-e9cb88b1edc2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "templateinstances/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:template-service-broker",
                "resourceVersion": "9663",
                "uid": "04463bce-1a1a-4ff7-a22f-aad5e87ae88f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.openshift.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "brokertemplateinstances"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "brokertemplateinstances/finalizers"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "templateinstances"
                    ],
                    "verbs": [
                        "assign",
                        "create",
                        "delete",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "template.openshift.io"
                    ],
                    "resources": [
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "services"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:controller:unidling-controller",
                "resourceVersion": "9658",
                "uid": "64db1ed0-601b-4d58-831f-be83eee767cb"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints",
                        "replicationcontrollers/scale",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "replicationcontrollers"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs"
                    ],
                    "verbs": [
                        "get",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "apps",
                        "extensions"
                    ],
                    "resources": [
                        "deployments/scale",
                        "replicasets/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:discovery",
                "resourceVersion": "9623",
                "uid": "970f2c0b-9205-4207-a6da-5a5d1085718c"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/version",
                        "/version/*",
                        "/api",
                        "/api/*",
                        "/apis",
                        "/apis/*",
                        "/oapi",
                        "/oapi/*",
                        "/openapi/v2",
                        "/swaggerapi",
                        "/swaggerapi/*",
                        "/swagger.json",
                        "/swagger-2.0.0.pb-v1",
                        "/osapi",
                        "/osapi/",
                        "/.well-known",
                        "/.well-known/oauth-authorization-server",
                        "/"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:47:02Z",
                "name": "system:openshift:kube-controller-manager:gce-cloud-provider",
                "resourceVersion": "5675",
                "uid": "7d0762d7-ef1a-42d7-9844-c6dc70f91784"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services/status"
                    ],
                    "verbs": [
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:28Z",
                "labels": {
                    "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
                },
                "name": "system:openshift:machine-config-operator:cluster-reader",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "953",
                "uid": "e0058cc4-1664-458c-a0e9-2d8ce734d124"
            },
            "rules": [
                {
                    "apiGroups": [
                        "machineconfiguration.openshift.io"
                    ],
                    "resources": [
                        "containerruntimeconfigs",
                        "controllerconfigs",
                        "kubeletconfigs",
                        "machineconfigpools"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:openshift-controller-manager",
                "resourceVersion": "4380",
                "uid": "b7b5f2c3-9640-47c8-b0fc-815ae5e0496a"
            },
            "rules": [
                {
                    "apiGroups": [
                        "*"
                    ],
                    "resources": [
                        "*"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:openshift-controller-manager:ingress-to-route-controller",
                "resourceVersion": "4388",
                "uid": "eabbc23d-865d-43f2-932c-5ae02ff5d82a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "secrets",
                        "services"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingress"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/custom-host"
                    ],
                    "verbs": [
                        "create",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:openshift-controller-manager:update-buildconfig-status",
                "resourceVersion": "4494",
                "uid": "889d6e79-32ee-471f-a27e-cda69e4362ea"
            },
            "rules": [
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/status"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true"
                },
                "creationTimestamp": "2021-11-10T06:42:38Z",
                "name": "system:openshift:operator:cloud-controller-manager",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1236",
                "uid": "ba6af51d-b1bd-41a9-9390-eb0adfaf6ea7"
            },
            "rules": [
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "clusteroperators"
                    ],
                    "verbs": [
                        "get",
                        "create",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resourceNames": [
                        "cloud-controller-manager"
                    ],
                    "resources": [
                        "clusteroperators/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "proxies"
                    ],
                    "verbs": [
                        "list",
                        "get",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "config.openshift.io"
                    ],
                    "resources": [
                        "infrastructures",
                        "featuregates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "kubecontrollermanagers"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:openshift:public-info-viewer",
                "resourceVersion": "101",
                "uid": "3ae12d20-6f13-4be1-8eb4-9e5b25f6bdee"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/.well-known",
                        "/.well-known/*"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:49Z",
                "name": "system:openshift:scc:anyuid",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "874",
                "uid": "cb02fc2c-61d6-4cbe-a6d7-650168a0c6e0"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "anyuid"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:49Z",
                "name": "system:openshift:scc:hostaccess",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1036",
                "uid": "bb96e066-e490-4265-96cf-5d67444f0b8f"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "hostaccess"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:50Z",
                "name": "system:openshift:scc:hostmount",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1123",
                "uid": "16cbb961-507b-4ae4-8c38-b647c11d8607"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "hostmount"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:50Z",
                "name": "system:openshift:scc:hostnetwork",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1193",
                "uid": "e6a39a84-bf4f-42ee-8e28-71a9e0e7f72b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "hostnetwork"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:51Z",
                "name": "system:openshift:scc:nonroot",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1238",
                "uid": "81494aa4-5d39-42a5-921a-4f612db7f5ad"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "nonroot"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:51Z",
                "name": "system:openshift:scc:privileged",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1296",
                "uid": "91e3b555-03f4-48b6-a5be-7db809115a65"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "privileged"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "include.release.openshift.io/ibm-cloud-managed": "true",
                    "include.release.openshift.io/self-managed-high-availability": "true",
                    "include.release.openshift.io/single-node-developer": "true",
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:51Z",
                "name": "system:openshift:scc:restricted",
                "ownerReferences": [
                    {
                        "apiVersion": "config.openshift.io/v1",
                        "kind": "ClusterVersion",
                        "name": "version",
                        "uid": "24d8a2df-a391-4a10-9f06-617071edd046"
                    }
                ],
                "resourceVersion": "1343",
                "uid": "bcc7ab7c-0b30-408a-9571-a52e51ddd122"
            },
            "rules": [
                {
                    "apiGroups": [
                        "security.openshift.io"
                    ],
                    "resourceNames": [
                        "restricted"
                    ],
                    "resources": [
                        "securitycontextconstraints"
                    ],
                    "verbs": [
                        "use"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:openshift:templateservicebroker-client",
                "resourceVersion": "9632",
                "uid": "09396098-5a2c-462e-93fb-bfc716959ef7"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/brokers/template.openshift.io/*"
                    ],
                    "verbs": [
                        "delete",
                        "get",
                        "put",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:46:51Z",
                "name": "system:openshift:tokenreview-openshift-controller-manager",
                "resourceVersion": "4396",
                "uid": "c284f7bf-e868-481c-b3ea-60f54583dd26"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:47:01Z",
                "name": "system:openshift:useroauthaccesstoken-manager",
                "resourceVersion": "5599",
                "uid": "42f1da45-a977-4828-87bb-676f3a11ae51"
            },
            "rules": [
                {
                    "apiGroups": [
                        "oauth.openshift.io"
                    ],
                    "resources": [
                        "useroauthaccesstokens"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:persistent-volume-provisioner",
                "resourceVersion": "119",
                "uid": "f5f52eaf-e5d9-4027-8593-3117c4e05c8a"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "events.k8s.io"
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:public-info-viewer",
                "resourceVersion": "103",
                "uid": "63fe57d9-fdb2-4e1c-b0da-3199424ae62c"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/healthz",
                        "/livez",
                        "/readyz",
                        "/version",
                        "/version/"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "imageregistry.operator.openshift.io/checksum": "sha256:693052fe8cd7138d0dbe6186d2d1dc6e308cb8a3063856ddf6fde9c61b28b8bb"
                },
                "creationTimestamp": "2021-11-10T06:57:01Z",
                "name": "system:registry",
                "resourceVersion": "18612",
                "uid": "96374e6b-1ac5-4b32-bcc9-eeec1c0d0cf0"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "limitranges",
                        "resourcequotas"
                    ],
                    "verbs": [
                        "list"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreams/layers",
                        "imagestreams/secrets"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamtags"
                    ],
                    "verbs": [
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "images"
                    ],
                    "verbs": [
                        "get",
                        "update"
                    ]
                },
                {
                    "apiGroups": [
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreammappings"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "operator.openshift.io"
                    ],
                    "resources": [
                        "imagecontentsourcepolicies"
                    ],
                    "verbs": [
                        "list"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:router",
                "resourceVersion": "9618",
                "uid": "5e6ae22e-6574-4c8f-af7c-841d78a8fb83"
            },
            "rules": [
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "endpoints"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "services"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:scope-impersonation",
                "resourceVersion": "9563",
                "uid": "1d2bf28b-2023-4cde-ba86-9c86f5c26bf8"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "userextras/scopes.authorization.openshift.io"
                    ],
                    "verbs": [
                        "impersonate"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:sdn-manager",
                "resourceVersion": "9621",
                "uid": "61f049ef-075f-481d-bcfc-910367bdaec3"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "hostsubnets",
                        "netnamespaces"
                    ],
                    "verbs": [
                        "create",
                        "delete",
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "clusternetworks"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:sdn-reader",
                "resourceVersion": "9620",
                "uid": "f72ed85e-4ce0-413b-afe4-3cb355149782"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "egressnetworkpolicies",
                        "hostsubnets",
                        "netnamespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "network.openshift.io"
                    ],
                    "resources": [
                        "clusternetworks"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "events"
                    ],
                    "verbs": [
                        "create",
                        "patch",
                        "update"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:service-account-issuer-discovery",
                "resourceVersion": "127",
                "uid": "67e27dd5-d0e7-4187-b62f-5f528babb4b4"
            },
            "rules": [
                {
                    "nonResourceURLs": [
                        "/.well-known/openid-configuration",
                        "/openid/v1/jwks"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults"
                },
                "name": "system:volume-scheduler",
                "resourceVersion": "122",
                "uid": "63d3ca15-a9ec-487c-8ec2-f8bc29a16798"
            },
            "rules": [
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "storage.k8s.io"
                    ],
                    "resources": [
                        "storageclasses"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "persistentvolumeclaims"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "patch",
                        "update",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:48:34Z",
                "name": "system:webhook",
                "resourceVersion": "9622",
                "uid": "194357f9-38cc-4362-8878-5e0836c5655b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs/webhooks"
                    ],
                    "verbs": [
                        "create",
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-d954f1473639740f-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "tailoredprofiles.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "tailoredprofiles.compliance.openshift.io",
                        "uid": "04f5cb83-f981-48ee-826c-c3f033e24b8d"
                    }
                ],
                "resourceVersion": "41097",
                "uid": "3ef9e22d-7db6-464a-bdbd-51cd47c1121b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-d954f1473639740f-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "tailoredprofiles.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "tailoredprofiles.compliance.openshift.io",
                        "uid": "04f5cb83-f981-48ee-826c-c3f033e24b8d"
                    }
                ],
                "resourceVersion": "41107",
                "uid": "006ca6ae-0ae0-4fa6-b1d7-c5985eacd89e"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-d954f1473639740f-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "tailoredprofiles.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "tailoredprofiles.compliance.openshift.io",
                        "uid": "04f5cb83-f981-48ee-826c-c3f033e24b8d"
                    }
                ],
                "resourceVersion": "41102",
                "uid": "537785b6-3fa1-43b0-9950-1dfcecc95aa2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-d954f1473639740f-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "tailoredprofiles.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "tailoredprofiles.compliance.openshift.io",
                        "uid": "04f5cb83-f981-48ee-826c-c3f033e24b8d"
                    }
                ],
                "resourceVersion": "41091",
                "uid": "e648b4ba-a116-4b46-9578-f6df7ba9db9b"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:48:00Z",
                "name": "telemeter-client",
                "resourceVersion": "8351",
                "uid": "10cbec1f-ba23-415f-9d23-d0058aca9181"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:57:16Z",
                "labels": {
                    "app.kubernetes.io/component": "query-layer",
                    "app.kubernetes.io/instance": "thanos-querier",
                    "app.kubernetes.io/name": "thanos-query",
                    "app.kubernetes.io/part-of": "openshift-monitoring",
                    "app.kubernetes.io/version": "0.22.0"
                },
                "name": "thanos-querier",
                "resourceVersion": "20001",
                "uid": "b7c1b72f-76d5-49b4-90da-862068fd65f5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "authentication.k8s.io"
                    ],
                    "resources": [
                        "tokenreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                },
                {
                    "apiGroups": [
                        "authorization.k8s.io"
                    ],
                    "resources": [
                        "subjectaccessreviews"
                    ],
                    "verbs": [
                        "create"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-admin": "true",
                    "rbac.authorization.k8s.io/aggregate-to-admin": "true"
                },
                "name": "variables.compliance.openshift.io-v1alpha1-admin",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "variables.compliance.openshift.io",
                        "uid": "b90dfc1a-8b00-4b8a-864a-1c1e7e18de3d"
                    }
                ],
                "resourceVersion": "41114",
                "uid": "f3ad5b51-d83a-49de-86af-55d4da2d33e2"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "*"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "variables.compliance.openshift.io-v1alpha1-crdview",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "variables.compliance.openshift.io",
                        "uid": "b90dfc1a-8b00-4b8a-864a-1c1e7e18de3d"
                    }
                ],
                "resourceVersion": "41126",
                "uid": "c0c87752-42d7-400d-8f8b-f43c0bf90821"
            },
            "rules": [
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-edit": "true",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "variables.compliance.openshift.io-v1alpha1-edit",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "variables.compliance.openshift.io",
                        "uid": "b90dfc1a-8b00-4b8a-864a-1c1e7e18de3d"
                    }
                ],
                "resourceVersion": "41118",
                "uid": "e185830d-30e7-4440-a00a-f29711721eb0"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T07:39:57Z",
                "labels": {
                    "olm.opgroup.permissions/aggregate-to-1592ac5e044b30c4-view": "true",
                    "rbac.authorization.k8s.io/aggregate-to-view": "true"
                },
                "name": "variables.compliance.openshift.io-v1alpha1-view",
                "ownerReferences": [
                    {
                        "apiVersion": "apiextensions.k8s.io/v1",
                        "blockOwnerDeletion": false,
                        "controller": false,
                        "kind": "CustomResourceDefinition",
                        "name": "variables.compliance.openshift.io",
                        "uid": "b90dfc1a-8b00-4b8a-864a-1c1e7e18de3d"
                    }
                ],
                "resourceVersion": "41121",
                "uid": "de850cc9-86d7-46f3-806b-34931cccc2bf"
            },
            "rules": [
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "aggregationRule": {
                "clusterRoleSelectors": [
                    {
                        "matchLabels": {
                            "rbac.authorization.k8s.io/aggregate-to-view": "true"
                        }
                    }
                ]
            },
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "annotations": {
                    "rbac.authorization.kubernetes.io/autoupdate": "true"
                },
                "creationTimestamp": "2021-11-10T06:41:40Z",
                "labels": {
                    "kubernetes.io/bootstrapping": "rbac-defaults",
                    "rbac.authorization.k8s.io/aggregate-to-edit": "true"
                },
                "name": "view",
                "resourceVersion": "41130",
                "uid": "7dd10170-a623-46aa-8546-7e1ce0ef31d5"
            },
            "rules": [
                {
                    "apiGroups": [
                        "operators.coreos.com"
                    ],
                    "resources": [
                        "clusterserviceversions",
                        "catalogsources",
                        "installplans",
                        "subscriptions",
                        "operatorgroups"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests",
                        "packagemanifests/icon"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancecheckresults.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancecheckresults"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "complianceremediations.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "complianceremediations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancescans.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancescans"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "compliancesuites.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "compliancesuites"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "packages.operators.coreos.com"
                    ],
                    "resources": [
                        "packagemanifests"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profilebundles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profilebundles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "profiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "profiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreamimages",
                        "imagestreammappings",
                        "imagestreams",
                        "imagestreamtags",
                        "imagetags"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/layers"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "project.openshift.io"
                    ],
                    "resources": [
                        "projects"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "rules.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "rules"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettingbindings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettingbindings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "scansettings.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "scansettings"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "configmaps",
                        "endpoints",
                        "persistentvolumeclaims",
                        "persistentvolumeclaims/status",
                        "pods",
                        "replicationcontrollers",
                        "replicationcontrollers/scale",
                        "serviceaccounts",
                        "services",
                        "services/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "bindings",
                        "events",
                        "limitranges",
                        "namespaces/status",
                        "pods/log",
                        "pods/status",
                        "replicationcontrollers/status",
                        "resourcequotas",
                        "resourcequotas/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "namespaces"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "discovery.k8s.io"
                    ],
                    "resources": [
                        "endpointslices"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apps"
                    ],
                    "resources": [
                        "controllerrevisions",
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "statefulsets",
                        "statefulsets/scale",
                        "statefulsets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "autoscaling"
                    ],
                    "resources": [
                        "horizontalpodautoscalers",
                        "horizontalpodautoscalers/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "batch"
                    ],
                    "resources": [
                        "cronjobs",
                        "cronjobs/status",
                        "jobs",
                        "jobs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "extensions"
                    ],
                    "resources": [
                        "daemonsets",
                        "daemonsets/status",
                        "deployments",
                        "deployments/scale",
                        "deployments/status",
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies",
                        "replicasets",
                        "replicasets/scale",
                        "replicasets/status",
                        "replicationcontrollers/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "policy"
                    ],
                    "resources": [
                        "poddisruptionbudgets",
                        "poddisruptionbudgets/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "networking.k8s.io"
                    ],
                    "resources": [
                        "ingresses",
                        "ingresses/status",
                        "networkpolicies"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "metrics.k8s.io"
                    ],
                    "resources": [
                        "pods",
                        "nodes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "snapshot.storage.k8s.io"
                    ],
                    "resources": [
                        "volumesnapshots"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildconfigs",
                        "buildconfigs/webhooks",
                        "builds"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "builds/log"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "build.openshift.io"
                    ],
                    "resources": [
                        "jenkins"
                    ],
                    "verbs": [
                        "view"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs",
                        "deploymentconfigs/scale"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "apps.openshift.io"
                    ],
                    "resources": [
                        "deploymentconfigs/log",
                        "deploymentconfigs/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "image.openshift.io"
                    ],
                    "resources": [
                        "imagestreams/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "quota.openshift.io"
                    ],
                    "resources": [
                        "appliedclusterresourcequotas"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "route.openshift.io"
                    ],
                    "resources": [
                        "routes/status"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "template.openshift.io"
                    ],
                    "resources": [
                        "processedtemplates",
                        "templateconfigs",
                        "templateinstances",
                        "templates"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "",
                        "build.openshift.io"
                    ],
                    "resources": [
                        "buildlogs"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "resourcequotausages"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "tailoredprofiles.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "tailoredprofiles"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                },
                {
                    "apiGroups": [
                        "apiextensions.k8s.io"
                    ],
                    "resourceNames": [
                        "variables.compliance.openshift.io"
                    ],
                    "resources": [
                        "customresourcedefinitions"
                    ],
                    "verbs": [
                        "get"
                    ]
                },
                {
                    "apiGroups": [
                        "compliance.openshift.io"
                    ],
                    "resources": [
                        "variables"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch"
                    ]
                }
            ]
        },
        {
            "apiVersion": "rbac.authorization.k8s.io/v1",
            "kind": "ClusterRole",
            "metadata": {
                "creationTimestamp": "2021-11-10T06:44:04Z",
                "name": "whereabouts-cni",
                "ownerReferences": [
                    {
                        "apiVersion": "operator.openshift.io/v1",
                        "blockOwnerDeletion": true,
                        "controller": true,
                        "kind": "Network",
                        "name": "cluster",
                        "uid": "30224b04-a2c9-4827-9d70-60c393a0efe8"
                    }
                ],
                "resourceVersion": "2612",
                "uid": "ba6be0bc-70e6-4786-9ff2-9929219f43b6"
            },
            "rules": [
                {
                    "apiGroups": [
                        "whereabouts.cni.cncf.io"
                    ],
                    "resources": [
                        "ippools",
                        "overlappingrangeipreservations"
                    ],
                    "verbs": [
                        "get",
                        "list",
                        "watch",
                        "create",
                        "update",
                        "patch",
                        "delete"
                    ]
                },
                {
                    "apiGroups": [
                        ""
                    ],
                    "resources": [
                        "pods"
                    ],
                    "verbs": [
                        "list"
                    ]
                }
            ]
        }
    ],
    "kind": "List",
    "metadata": {
        "resourceVersion": "",
        "selfLink": ""
    }
}
EOF
