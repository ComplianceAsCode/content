#!/bin/bash

# remediation = none

yum install -y jq

# Create infra file for CPE to pass
mkdir -p "/etc/kubernetes"

cat <<EOF > "/etc/kubernetes/kubelet.conf"
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  x509:
    clientCAFile: /etc/kubernetes/kubelet-ca.crt
  anonymous:
    enabled: false
cgroupDriver: systemd
cgroupRoot: /
clusterDNS:
  - 10.217.4.10
clusterDomain: cluster.local
containerLogMaxSize: 50Mi
maxPods: 250
kubeAPIQPS: 50
kubeAPIBurst: 100
rotateCertificates: true
serializeImagePulls: false
staticPodPath: /etc/kubernetes/manifests
systemCgroups: /system.slice
systemReserved:
  ephemeral-storage: 1Gi
featureGates:
  APIPriorityAndFairness: true
  LegacyNodeRoleBehavior: false
  NodeDisruptionExclusion: true
  RotateKubeletServerCertificate: true
  ServiceNodeExclusion: true
  SupportPodPidsLimit: true
  DownwardAPIHugePages: true
serverTLSBootstrap: true
tlsMinVersion: VersionTLS12
tlsCipherSuites:
  - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
  - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
  - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
  - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
  - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
  - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
EOF
