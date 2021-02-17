#!/bin/bash
#
# This waits for etcd encryption to be enabled. The operator can apply the
# remediation, but waiting for this to get applied is still something that
# needs to be done outside of the operator.
#
# This patch sets the encryption setting and waits for it to be applied

while true; do
    status=$(oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}')

    echo "Current Encryption Status:"
    oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'

    if [ "$status" == "EncryptionCompleted" ]; then
        exit 0
    fi

    sleep 5
done
