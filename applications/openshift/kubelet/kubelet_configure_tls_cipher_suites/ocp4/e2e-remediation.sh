#!/bin/bash

cat << EOS | oc apply -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: tls-ciphers
spec:
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: tls-ciphers
  kubeletConfig:
    tlsCipherSuites:
    - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
EOS

overwrite_flag=''
if [ "$(oc get machineconfigpool worker -o=jsonpath='{.metadata.labels.custom-kubelet}')" != "" ] ; then
  overwrite_flag='--overwrite'
fi

oc label ${overwrite_flag} machineconfigpool worker custom-kubelet=tls-ciphers