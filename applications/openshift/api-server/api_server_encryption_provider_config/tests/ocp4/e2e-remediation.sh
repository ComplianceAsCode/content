#!/bin/bash
#
# This applies the remediation needed for this rule. Which enables etcd encryption
# This rule wasn't able to be done via a standard remediation since we only need to
# apply a partial part of the Kubernetes object. PATCH support for the
# compliance-operator would be needed to make this work
#
# This patch sets the encryption setting and waits for it to be applied

oc patch apiservers cluster -p '{"spec":{"encryption":{"type":"aescbc"}}}' --type=merge

while true; do
    status=$(oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}')

    echo "Current Encryption Status:"
    oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'

    if [ "$status" == "EncryptionCompleted" ]; then
        exit 0
    fi

    sleep 5
done