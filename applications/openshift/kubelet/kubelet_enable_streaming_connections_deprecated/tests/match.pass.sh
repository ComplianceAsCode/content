#!/bin/bash
# remediation = none
# variables = var_streaming_connection_timeouts=5m0s

yum install -y jq

mkdir -p "/etc/kubernetes"

cat << EOF > /etc/kubernetes/kubelet.conf
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "staticPodPath": "/etc/kubernetes/manifests",
  "syncFrequency": "0s",
  "fileCheckFrequency": "0s",
  "httpCheckFrequency": "0s",
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
      "cacheTTL": "0s"
    },
    "anonymous": {
      "enabled": false
    }
  },
  "authorization": {
    "webhook": {
      "cacheAuthorizedTTL": "0s",
      "cacheUnauthorizedTTL": "0s"
    }
  },
  "clusterDomain": "cluster.local",
  "clusterDNS": [
    "172.30.0.10"
  ],
  "streamingConnectionIdleTimeout": "5m0s",
  "nodeStatusUpdateFrequency": "0s",
  "nodeStatusReportFrequency": "0s",
  "imageMinimumGCAge": "0s",
  "volumeStatsAggPeriod": "0s",
  "systemCgroups": "/system.slice",
  "cgroupRoot": "/",
  "cgroupDriver": "systemd",
  "cpuManagerReconcilePeriod": "0s",
  "runtimeRequestTimeout": "0s",
  "maxPods": 250,
  "kubeAPIQPS": 50,
  "kubeAPIBurst": 100,
  "serializeImagePulls": false,
  "evictionPressureTransitionPeriod": "0s",
  "featureGates": {
    "APIPriorityAndFairness": true,
    "CSIMigrationAWS": false,
    "CSIMigrationAzureDisk": false,
    "CSIMigrationAzureFile": false,
    "CSIMigrationGCE": false,
    "CSIMigrationOpenStack": false,
    "CSIMigrationvSphere": false,
    "DownwardAPIHugePages": true,
    "LegacyNodeRoleBehavior": false,
    "NodeDisruptionExclusion": true,
    "PodSecurity": true,
    "RotateKubeletServerCertificate": true,
    "ServiceNodeExclusion": true,
    "SupportPodPidsLimit": true
  },
  "memorySwap": {},
  "containerLogMaxSize": "50Mi",
  "systemReserved": {
    "ephemeral-storage": "1Gi"
  },
  "logging": {
    "flushFrequency": 0,
    "verbosity": 0,
    "options": {
      "json": {
        "infoBufferSize": "0"
      }
    }
  },
  "shutdownGracePeriod": "5m",
  "shutdownGracePeriodCriticalPods": "0s"
}
EOF

