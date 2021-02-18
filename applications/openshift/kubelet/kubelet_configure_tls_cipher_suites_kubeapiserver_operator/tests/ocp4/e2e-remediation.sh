#!/bin/bash

oc patch kubeapiservers.operator.openshift.io cluster --type merge -p '{"spec":{"unsupportedConfigOverrides":{"servingInfo":{"cipherSuites":["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256","TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305","TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384","TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305","TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384","TLS_RSA_WITH_AES_256_GCM_SHA384","TLS_RSA_WITH_AES_128_GCM_SHA256"]}}}}'
while true; do
    after=$(oc get kubeapiservers.operator.openshift.io cluster -o=jsonpath='{.spec.unsupportedConfigOverrides}')
    if [ "${after}" != "<nil>" ] ; then
        break
    fi
    sleep 5
done
