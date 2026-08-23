#!/bin/bash
set -xe

echo "Adding Google IdP"

oc create secret generic google-secret -n openshift-config --from-literal="clientSecret="testsec""

sleep 5

cat << EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: googleidp 
    mappingMethod: claim 
    type: Google
    google:
      clientID: testclientid
      clientSecret: 
        name: google-secret
      hostedDomain: "example.com"
EOF


echo "waiting for a stable cluster"
oc adm wait-for-stable-cluster --minimum-stable-period 2m
