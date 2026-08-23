#!/bin/bash
# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"
ocp_apipath="/api/v1/namespaces/openshift-apiserver/configmaps/config"

mkdir -p "$kube_apipath/api/v1/namespaces/openshift-apiserver/configmaps/"

jq_filter_default='.data."config.yaml" | fromjson'

jq_filter='.data."config.yaml" | fromjson'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath$ocp_apipath#$(echo -n "$ocp_apipath$jq_filter_default" | sha256sum | awk '{print $1}')"

cat << EOF > $kube_apipath$ocp_apipath
{
    "apiVersion": "v1",
    "data": {
        "config.yaml": "{\"apiServerArguments\":{\"audit-log-format\":[\"json\"],\"audit-log-maxbackup\":[\"10\"],\"audit-log-maxsize\":[\"100\"],\"audit-log-path\":[\"/var/log/openshift-apiserver/audit.log\"],\"audit-policy-file\":[\"/var/run/configmaps/audit/policy.yaml\"],\"shutdown-delay-duration\":[\"15s\"],\"shutdown-send-retry-after\":[\"true\"]},\"apiVersion\":\"openshiftcontrolplane.config.openshift.io/v1\",\"imagePolicyConfig\":{\"internalRegistryHostname\":\"image-registry.openshift-image-registry.svc:5000\"},\"kind\":\"OpenShiftAPIServerConfig\",\"projectConfig\":{\"projectRequestMessage\":\"\"},\"routingConfig\":{\"subdomain\":\"apps.ci-ln-xllhdgb-76ef8.origin-ci-int-aws.dev.rhcloud.com\"},\"servingInfo\":{\"bindNetwork\":\"tcp\",\"cipherSuites\":[\"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\",\"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\",\"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\",\"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\",\"TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256\",\"TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256\"],\"minTLSVersion\":\"VersionTLS12\"},\"storageConfig\":{\"urls\":[\"https://10.0.137.27:2379\",\"https://10.0.158.132:2379\",\"https://10.0.204.8:2379\"]}}"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2023-02-28T05:44:46Z",
        "name": "config",
        "namespace": "openshift-apiserver",
        "resourceVersion": "20949",
        "uid": "50c1c8ce-5ae3-465d-b60c-47ef2208f665"
    }
}
EOF

jq "$jq_filter" "$kube_apipath$ocp_apipath" > "$filteredpath"

