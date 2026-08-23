#!/bin/bash
# remediation = none
yum install -y jq

kube_apipath="/kubernetes-api-resources"

mkdir -p "$kube_apipath/api/v1/namespaces/openshift-kube-controller-manager/configmaps"

config_apipath="/api/v1/namespaces/openshift-kube-controller-manager/configmaps/config"

cat << EOF > "$kube_apipath$config_apipath"
{
    "apiVersion": "v1",
    "data": {
        "config.yaml": "{\"apiVersion\":\"kubecontrolplane.config.openshift.io/v1\",\"extendedArguments\":{\"allocate-node-cidrs\":[\"false\"],\"cert-dir\":[\"/var/run/kubernetes\"],\"cloud-provider\":[\"aws\"],\"cluster-cidr\":[\"10.128.0.0/14\"],\"cluster-name\":[\"wenshen-51-f2xqb\"],\"cluster-signing-cert-file\":[\"/etc/kubernetes/static-pod-certs/secrets/csr-signer/tls.crt\"],\"cluster-signing-key-file\":[\"/etc/kubernetes/static-pod-certs/secrets/csr-signer/tls.key\"],\"configure-cloud-routes\":[\"false\"],\"controllers\":[\"*\",\"-ttl\",\"-bootstrapsigner\",\"-tokencleaner\"],\"enable-dynamic-provisioning\":[\"true\"],\"experimental-cluster-signing-duration\":[\"720h\"],\"feature-gates\":[\"APIPriorityAndFairness=true\",\"RotateKubeletServerCertificate=true\",\"SupportPodPidsLimit=true\",\"NodeDisruptionExclusion=true\",\"ServiceNodeExclusion=true\",\"DownwardAPIHugePages=true\",\"LegacyNodeRoleBehavior=false\"],\"flex-volume-plugin-dir\":[\"/etc/kubernetes/kubelet-plugins/volume/exec\"],\"kube-api-burst\":[\"300\"],\"kube-api-qps\":[\"150\"],\"leader-elect\":[\"true\"],\"leader-elect-resource-lock\":[\"configmaps\"],\"leader-elect-retry-period\":[\"3s\"],\"port\":[\"8080\"],\"pv-recycler-pod-template-filepath-hostpath\":[\"/etc/kubernetes/static-pod-resources/configmaps/recycler-config/recycler-pod.yaml\"],\"pv-recycler-pod-template-filepath-nfs\":[\"/etc/kubernetes/static-pod-resources/configmaps/recycler-config/recycler-pod.yaml\"],\"root-ca-file\":[\"/etc/kubernetes/static-pod-resources/configmaps/serviceaccount-ca/ca-bundle.crt\"],\"secure-port\":[\"10257\"],\"service-account-private-key-file\":[\"/etc/kubernetes/static-pod-resources/secrets/service-account-private-key/service-account.key\"],\"service-cluster-ip-range\":[\"172.30.0.0/16\"],\"use-service-account-credentials\":[\"true\"]},\"kind\":\"KubeControllerManagerConfig\",\"serviceServingCert\":{\"certFile\":\"/etc/kubernetes/static-pod-resources/configmaps/service-ca/ca-bundle.crt\"}}"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-01-24T15:53:46Z",
        "name": "config",
        "namespace": "openshift-kube-controller-manager",
        "resourceVersion": "6094",
        "uid": "cbaf5bbe-1847-433e-812d-e9c12c254547"
    }
}
EOF

jq_filter='[.data."config.yaml" | fromjson | if .extendedArguments["port"]!=null then .extendedArguments["port"]==["0"] else true end]'

# Get file path. This will actually be read by the scan
filteredpath="$kube_apipath$config_apipath#$(echo -n "$config_apipath$jq_filter" | sha256sum | awk '{print $1}')"

# populate filtered path with jq-filtered result
jq "$jq_filter" "$kube_apipath$config_apipath" > "$filteredpath" 


