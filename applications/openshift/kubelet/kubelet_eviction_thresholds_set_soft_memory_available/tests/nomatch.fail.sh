#!/bin/bash
# remediation = none

kube_apipath="/kubernetes-api-resources"
ocp_apipath="/apis/config.openshift.io/v1/clusteroperators/openshift-apiserver"
api_path_worker="/kubeletconfig/role/worker"
api_path_master="/kubeletconfig/role/master"

mkdir -p "$kube_apipath/apis/config.openshift.io/v1/clusteroperators/"
mkdir -p "$kube_apipath/kubeletconfig/role"

cat << EOF > $kube_apipath$ocp_apipath
{
   "apiVersion":"config.openshift.io/v1",
   "kind":"ClusterOperator",
   "metadata":{
      "annotations":{
         "exclude.release.openshift.io/internal-openshift-hosted":"true",
         "include.release.openshift.io/self-managed-high-availability":"true",
         "include.release.openshift.io/single-node-developer":"true"
      },
      "creationTimestamp":"2022-08-10T00:56:27Z",
      "generation":1,
      "name":"openshift-apiserver",
      "ownerReferences":[
         {
            "apiVersion":"config.openshift.io/v1",
            "kind":"ClusterVersion",
            "name":"version",
            "uid":"c28a5c07-152f-4fec-b51e-c53f64585841"
         }
      ],
      "resourceVersion":"26181",
      "uid":"f8b3e53e-fe06-466e-9842-2cad5ef1659f"
   },
   "spec":{
      
   },
   "status":{
      "conditions":[
         {
            "lastTransitionTime":"2022-08-10T01:03:54Z",
            "message":"All is well",
            "reason":"AsExpected",
            "status":"False",
            "type":"Degraded"
         },
         {
            "lastTransitionTime":"2022-08-10T01:11:26Z",
            "message":"All is well",
            "reason":"AsExpected",
            "status":"False",
            "type":"Progressing"
         },
         {
            "lastTransitionTime":"2022-08-10T01:14:55Z",
            "message":"All is well",
            "reason":"AsExpected",
            "status":"True",
            "type":"Available"
         },
         {
            "lastTransitionTime":"2022-08-10T01:01:44Z",
            "message":"All is well",
            "reason":"AsExpected",
            "status":"True",
            "type":"Upgradeable"
         }
      ],
      "extension":null,
      "relatedObjects":[
         {
            "group":"operator.openshift.io",
            "name":"cluster",
            "resource":"openshiftapiservers"
         },
         {
            "group":"",
            "name":"openshift-config",
            "resource":"namespaces"
         },
         {
            "group":"",
            "name":"openshift-config-managed",
            "resource":"namespaces"
         },
         {
            "group":"",
            "name":"openshift-apiserver-operator",
            "resource":"namespaces"
         },
         {
            "group":"",
            "name":"openshift-apiserver",
            "resource":"namespaces"
         },
         {
            "group":"",
            "name":"openshift-etcd-operator",
            "resource":"namespaces"
         },
         {
            "group":"",
            "name":"host-etcd-2",
            "namespace":"openshift-etcd",
            "resource":"endpoints"
         },
         {
            "group":"controlplane.operator.openshift.io",
            "name":"",
            "namespace":"openshift-apiserver",
            "resource":"podnetworkconnectivitychecks"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.apps.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.authorization.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.build.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.image.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.project.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.quota.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.route.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.security.openshift.io",
            "resource":"apiservices"
         },
         {
            "group":"apiregistration.k8s.io",
            "name":"v1.template.openshift.io",
            "resource":"apiservices"
         }
      ],
      "versions":[
         {
            "name":"operator",
            "version":"4.11.0-0.ci-2022-08-08-193848"
         },
         {
            "name":"openshift-apiserver",
            "version":"4.11.0-0.ci-2022-08-08-193848"
         }
      ]
   }
}
EOF

cat << EOF > $kube_apipath$api_path_worker
{
  "enableServer": true,
  "staticPodPath": "/etc/kubernetes/manifests",
  "syncFrequency": "1m0s",
  "fileCheckFrequency": "20s",
  "httpCheckFrequency": "20s",
  "address": "0.0.0.0",
  "port": 10250,
  "tlsCipherSuites": [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  ],
  "tlsMinVersion": "VersionTLS12",
  "rotateCertificates": true,
  "serverTLSBootstrap": true,
  "authentication": {
    "x509": {
      "clientCAFile": "/etc/kubernetes/kubelet-ca.crt"
    },
    "webhook": {
      "enabled": true,
      "cacheTTL": "2m0s"
    },
    "anonymous": {
      "enabled": false
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "registryPullQPS": 5,
  "registryBurst": 10,
  "eventRecordQPS": 5,
  "eventBurst": 10,
  "enableDebuggingHandlers": true,
  "healthzPort": 10248,
  "healthzBindAddress": "127.0.0.1",
  "oomScoreAdj": -999,
  "clusterDomain": "cluster.local",
  "clusterDNS": [
    "172.30.0.10"
  ],
  "streamingConnectionIdleTimeout": "5m0s",
  "nodeStatusUpdateFrequency": "10s",
  "nodeStatusReportFrequency": "5m0s",
  "nodeLeaseDurationSeconds": 40,
  "imageMinimumGCAge": "2m0s",
  "imageGCHighThresholdPercent": 85,
  "imageGCLowThresholdPercent": 80,
  "volumeStatsAggPeriod": "1m0s",
  "systemCgroups": "/system.slice",
  "cgroupRoot": "/",
  "cgroupsPerQOS": true,
  "cgroupDriver": "systemd",
  "cpuManagerPolicy": "none",
  "cpuManagerReconcilePeriod": "10s",
  "memoryManagerPolicy": "None",
  "topologyManagerPolicy": "none",
  "topologyManagerScope": "container",
  "runtimeRequestTimeout": "2m0s",
  "hairpinMode": "promiscuous-bridge",
  "maxPods": 250,
  "podPidsLimit": 4096,
  "resolvConf": "/etc/resolv.conf",
  "cpuCFSQuota": true,
  "cpuCFSQuotaPeriod": "100ms",
  "nodeStatusMaxImages": 50,
  "maxOpenFiles": 1000000,
  "contentType": "application/vnd.kubernetes.protobuf",
  "kubeAPIQPS": 50,
  "kubeAPIBurst": 100,
  "serializeImagePulls": false,
  "evictionSoft": {
    "imagefs.available": "10%",
    "imagefs.inodesfree": "10%",
    "memory.available": "200Mi",
    "nodefs.available": "10%",
    "nodefs.inodesFree": "5%"
  },
  "evictionPressureTransitionPeriod": "5m0s",
  "enableControllerAttachDetach": true,
  "makeIPTablesUtilChains": true,
  "iptablesMasqueradeBit": 14,
  "iptablesDropBit": 15,
  "featureGates": {
    "APIPriorityAndFairness": true,
    "CSIMigrationAWS": false,
    "CSIMigrationAzureFile": false,
    "CSIMigrationGCE": false,
    "CSIMigrationvSphere": false,
    "DownwardAPIHugePages": true,
    "PodSecurity": true,
    "RotateKubeletServerCertificate": true
  },
  "failSwapOn": true,
  "memorySwap": {},
  "containerLogMaxSize": "50Mi",
  "containerLogMaxFiles": 5,
  "configMapAndSecretChangeDetectionStrategy": "Watch",
  "systemReserved": {
    "cpu": "500m",
    "memory": "1Gi"
  },
  "enforceNodeAllocatable": [
    "pods"
  ],
  "volumePluginDir": "/etc/kubernetes/kubelet-plugins/volume/exec",
  "logging": {
    "format": "text",
    "flushFrequency": 5000000000,
    "verbosity": 2,
    "options": {
      "json": {
        "infoBufferSize": "0"
      }
    }
  },
  "enableSystemLogHandler": true,
  "shutdownGracePeriod": "0s",
  "shutdownGracePeriodCriticalPods": "0s",
  "enableProfilingHandler": true,
  "enableDebugFlagsHandler": true,
  "seccompDefault": false,
  "memoryThrottlingFactor": 0.8,
  "registerWithTaints": [
    {
      "key": "node-role.kubernetes.io/master",
      "effect": "NoSchedule"
    }
  ],
  "registerNode": true,
  "kind": "KubeletConfiguration"
}
EOF


cat << EOF > $kube_apipath$api_path_master
{
  "enableServer": true,
  "staticPodPath": "/etc/kubernetes/manifests",
  "syncFrequency": "1m0s",
  "fileCheckFrequency": "20s",
  "httpCheckFrequency": "20s",
  "address": "0.0.0.0",
  "port": 10250,
  "tlsCipherSuites": [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  ],
  "tlsMinVersion": "VersionTLS12",
  "rotateCertificates": true,
  "serverTLSBootstrap": true,
  "authentication": {
    "x509": {
      "clientCAFile": "/etc/kubernetes/kubelet-ca.crt"
    },
    "webhook": {
      "enabled": true,
      "cacheTTL": "2m0s"
    },
    "anonymous": {
      "enabled": false
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "registryPullQPS": 5,
  "registryBurst": 10,
  "eventRecordQPS": 5,
  "eventBurst": 10,
  "enableDebuggingHandlers": true,
  "healthzPort": 10248,
  "healthzBindAddress": "127.0.0.1",
  "oomScoreAdj": -999,
  "clusterDomain": "cluster.local",
  "clusterDNS": [
    "172.30.0.10"
  ],
  "streamingConnectionIdleTimeout": "5m0s",
  "nodeStatusUpdateFrequency": "10s",
  "nodeStatusReportFrequency": "5m0s",
  "nodeLeaseDurationSeconds": 40,
  "imageMinimumGCAge": "2m0s",
  "imageGCHighThresholdPercent": 85,
  "imageGCLowThresholdPercent": 80,
  "volumeStatsAggPeriod": "1m0s",
  "systemCgroups": "/system.slice",
  "cgroupRoot": "/",
  "cgroupsPerQOS": true,
  "cgroupDriver": "systemd",
  "cpuManagerPolicy": "none",
  "cpuManagerReconcilePeriod": "10s",
  "memoryManagerPolicy": "None",
  "topologyManagerPolicy": "none",
  "topologyManagerScope": "container",
  "runtimeRequestTimeout": "2m0s",
  "hairpinMode": "promiscuous-bridge",
  "maxPods": 250,
  "podPidsLimit": 4096,
  "resolvConf": "/etc/resolv.conf",
  "cpuCFSQuota": true,
  "cpuCFSQuotaPeriod": "100ms",
  "nodeStatusMaxImages": 50,
  "maxOpenFiles": 1000000,
  "contentType": "application/vnd.kubernetes.protobuf",
  "kubeAPIQPS": 50,
  "kubeAPIBurst": 100,
  "serializeImagePulls": false,
  "evictionSoft": {
    "imagefs.available": "10%",
    "imagefs.inodesfree": "10%",
    "memory.available": "300Mi",
    "nodefs.available": "10%",
    "nodefs.inodesFree": "5%"
  },
  "evictionPressureTransitionPeriod": "5m0s",
  "enableControllerAttachDetach": true,
  "makeIPTablesUtilChains": true,
  "iptablesMasqueradeBit": 14,
  "iptablesDropBit": 15,
  "featureGates": {
    "APIPriorityAndFairness": true,
    "CSIMigrationAWS": false,
    "CSIMigrationAzureFile": false,
    "CSIMigrationGCE": false,
    "CSIMigrationvSphere": false,
    "DownwardAPIHugePages": true,
    "PodSecurity": true,
    "RotateKubeletServerCertificate": true
  },
  "failSwapOn": true,
  "memorySwap": {},
  "containerLogMaxSize": "50Mi",
  "containerLogMaxFiles": 5,
  "configMapAndSecretChangeDetectionStrategy": "Watch",
  "systemReserved": {
    "cpu": "500m",
    "memory": "1Gi"
  },
  "enforceNodeAllocatable": [
    "pods"
  ],
  "volumePluginDir": "/etc/kubernetes/kubelet-plugins/volume/exec",
  "logging": {
    "format": "text",
    "flushFrequency": 5000000000,
    "verbosity": 2,
    "options": {
      "json": {
        "infoBufferSize": "0"
      }
    }
  },
  "enableSystemLogHandler": true,
  "shutdownGracePeriod": "0s",
  "shutdownGracePeriodCriticalPods": "0s",
  "enableProfilingHandler": true,
  "enableDebugFlagsHandler": true,
  "seccompDefault": false,
  "memoryThrottlingFactor": 0.8,
  "registerWithTaints": [
    {
      "key": "node-role.kubernetes.io/master",
      "effect": "NoSchedule"
    }
  ],
  "registerNode": true,
  "kind": "KubeletConfiguration"
}
EOF