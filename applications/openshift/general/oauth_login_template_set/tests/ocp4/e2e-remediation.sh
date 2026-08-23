#!/bin/bash

oc adm create-provider-selection-template > providers.html
oc create secret generic providers-template --from-file=providers.html -n openshift-config
rm -f providers.html

oc adm create-login-template > login.html
oc create secret generic login-template --from-file=login.html -n openshift-config
rm -f login.html

oc patch oauths cluster --type='merge' -p '{"spec":{"templates":{"login":{"name":"login-template"},"providerSelection":{"name":"providers-template"}}}}'
