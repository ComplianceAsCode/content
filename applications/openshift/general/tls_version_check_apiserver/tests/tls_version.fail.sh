#!/bin/bash

# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"

# Create infra file for CPE to pass

mkdir -p "$kube_apipath/api/v1/namespaces/openshift-apiserver/configmaps"
config_apipath="/api/v1/namespaces/openshift-apiserver/configmaps/config"
cat <<EOF > "$kube_apipath/api/v1/namespaces/openshift-apiserver/configmaps/config"

{
    "apiVersion": "v1",
    "data": {
        "config.yaml": "{\"apiServerArguments\":{\"audit-log-format\":[\"json\"],\"audit-log-maxbackup\":[\"10\"],\"audit-log-maxsize\":[\"100\"],\"audit-log-path\":[\"/var/log/openshift-apiserver/audit.log\"],\"audit-policy-file\":[\"/var/run/configmaps/audit/policy.yaml\"],\"shutdown-delay-duration\":[\"10s\"]},\"apiVersion\":\"openshiftcontrolplane.config.openshift.io/v1\",\"imagePolicyConfig\":{\"externalRegistryHostnames\":[\"default-route-openshift-image-registry.apps-crc.testing\"],\"internalRegistryHostname\":\"image-registry.openshift-image-registry.svc:5000\"},\"kind\":\"OpenShiftAPIServerConfig\",\"projectConfig\":{\"projectRequestMessage\":\"\"},\"routingConfig\":{\"subdomain\":\"apps-crc.testing\"},\"servingInfo\":{\"bindNetwork\":\"tcp\",\"cipherSuites\":[\"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256\",\"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256\"],\"minTLSVersion\":\"VersionTLS11\"},\"storageConfig\":{\"urls\":[\"https://192.168.126.11:2379\"]}}"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2021-10-14T03:46:50Z",
        "name": "config",
        "namespace": "openshift-apiserver",
        "resourceVersion": "19457",
        "uid": "3222a317-422d-4355-94cd-d64ffd757a7c"
    }
}
EOF


# Get file path. This will actually be read by the scan
filepath="$kube_apipath$config_apipath#$(echo -n "$config_apipath" | sha256sum | awk '{print $1}')"
