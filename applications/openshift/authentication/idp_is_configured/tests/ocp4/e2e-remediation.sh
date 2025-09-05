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


echo "waiting for authentication operator to become progressing"
oc wait clusteroperator authentication --for=condition=PROGRESSING

echo "waiting for authentication operator to become ready"
oc wait clusteroperator authentication --for=condition=Available
