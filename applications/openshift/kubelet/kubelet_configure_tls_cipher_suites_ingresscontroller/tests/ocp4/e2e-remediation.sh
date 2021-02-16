#!/bin/bash

namespace=openshift-ingress-operator
resource='ingresscontroller/default'
before=$(oc -n ${namespace} get ${resource} -o jsonpath='{.status.tlsProfile.ciphers[*]}')
oc -n ${namespace} patch ${resource} --type merge -p '{"spec":{"tlsSecurityProfile":{"type":"Custom","custom":{"ciphers":["ECDHE-ECDSA-AES128-GCM-SHA256","ECDHE-RSA-AES128-GCM-SHA256","ECDHE-RSA-AES256-GCM-SHA384"],"minTLSVersion":"VersionTLS12"}}}}'

while true; do
    after=$(oc -n ${namespace} get ${resource} -o jsonpath='{.status.tlsProfile.ciphers[*]}')
    if [ "${before}" != "${after}" ] ; then
        break
    fi
    sleep 5
done
