#!/bin/bash
# remediation = none

yum install -y jq

kube_apipath="/kubernetes-api-resources"
ocp_apipath="/api/v1/namespaces/openshift-apiserver/configmaps/config"

mkdir -p "$kube_apipath/api/v1/namespaces/openshift-apiserver/configmaps/"

jq_filter_default='.data."config.yaml" | fromjson'

jq_filter='.data."config.yaml"'

# Get filtered path. This will actually be read by the scan
filteredpath="$kube_apipath$ocp_apipath#$(echo -n "$ocp_apipath$jq_filter_default" | sha256sum | awk '{print $1}')"

cat << EOF > $kube_apipath$ocp_apipath
{"kind":"ConfigMap","apiVersion":"v1","metadata":{"name":"openshift-apiserver","namespace":"clusters-wenshen-hypershift","uid":"5ec57109-8d0d-46a0-8c6e-b711afa03dec","resourceVersion":"158040","creationTimestamp":"2023-02-27T21:49:46Z","ownerReferences":[{"apiVersion":"hypershift.openshift.io/v1beta1","kind":"HostedControlPlane","name":"wenshen-hypershift","uid":"50a4550a-e450-4546-a7b4-254011fc5dfe","controller":true,"blockOwnerDeletion":true}],"managedFields":[{"manager":"hypershift-controlplane-manager","operation":"Update","apiVersion":"v1","time":"2023-02-27T21:49:46Z","fieldsType":"FieldsV1","fieldsV1":{"f:data":{".":{},"f:config.yaml":{}},"f:metadata":{"f:ownerReferences":{".":{},"k:{\"uid\":\"50a4550a-e450-4546-a7b4-254011fc5dfe\"}":{}}}}}]},"data":{"config.yaml":"admission: {}\naggregatorConfig:\n  allowedNames: null\n  clientCA: \"\"\n  extraHeaderPrefixes: null\n  groupHeaders: null\n  usernameHeaders: null\napiServerArguments:\n  audit-log-format:\n  - json\n  audit-log-maxsize:\n  - \"50\"\n  audit-log-path:\n  - /var/log/openshift-apiserver/audit.log\n  audit-policy-file:\n  - /etc/kubernetes/audit-config/policy.yaml\n  shutdown-delay-duration:\n  - 3s\napiVersion: openshiftcontrolplane.config.openshift.io/v1\nauditConfig:\n  auditFilePath: \"\"\n  enabled: false\n  logFormat: \"\"\n  maximumFileRetentionDays: 0\n  maximumFileSizeMegabytes: 0\n  maximumRetainedFiles: 0\n  policyConfiguration: null\n  policyFile: \"\"\n  webHookKubeConfig: \"\"\n  webHookMode: \"\"\ncloudProviderFile: \"\"\ncorsAllowedOrigins: null\nimagePolicyConfig:\n  additionalTrustedCA: \"\"\n  allowedRegistriesForImport: null\n  externalRegistryHostnames: null\n  internalRegistryHostname: image-registry.openshift-image-registry.svc:5000\n  maxImagesBulkImportedPerRepository: 0\njenkinsPipelineConfig:\n  autoProvisionEnabled: null\n  parameters: null\n  serviceName: \"\"\n  templateName: \"\"\n  templateNamespace: \"\"\nkind: OpenShiftAPIServerConfig\nkubeClientConfig:\n  connectionOverrides:\n    acceptContentTypes: \"\"\n    burst: 0\n    contentType: \"\"\n    qps: 0\n  kubeConfig: /etc/kubernetes/secrets/svc-kubeconfig/kubeconfig\nprojectConfig:\n  defaultNodeSelector: \"\"\n  projectRequestMessage: \"\"\n  projectRequestTemplate: \"\"\nroutingConfig:\n  subdomain: apps.wenshen-hypershift.devcluster.openshift.com\nserviceAccountOAuthGrantMethod: \"\"\nservingInfo:\n  bindAddress: \"\"\n  bindNetwork: \"\"\n  certFile: /etc/kubernetes/certs/serving/tls.crt\n  cipherSuites:\n  - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256\n  - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\n  - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384\n  - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\n  - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256\n  - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256\n  clientCA: /etc/kubernetes/certs/client-ca/ca.crt\n  keyFile: /etc/kubernetes/certs/serving/tls.key\n  maxRequestsInFlight: 0\n  minTLSVersion: VersionTLS02\n  requestTimeoutSeconds: 0\nstorageConfig:\n  ca: /etc/kubernetes/certs/etcd-client-ca/ca.crt\n  certFile: /etc/kubernetes/certs/etcd-client/etcd-client.crt\n  keyFile: /etc/kubernetes/certs/etcd-client/etcd-client.key\n  storagePrefix: \"\"\n  urls:\n  - https://etcd-client:2379\n"}}
EOF

jq -r "$jq_filter" "$kube_apipath$ocp_apipath" > "$filteredpath"

