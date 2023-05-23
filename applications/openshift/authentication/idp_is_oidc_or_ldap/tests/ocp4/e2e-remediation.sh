#!/bin/bash
set -xe

echo "Adding LDAP IDP"

oc create secret generic ldapbindpassword -n openshift-config --from-literal="bindPassword="testsec""

sleep 5

cat << EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
   - name: example-ldap
     type: LDAP
     ldap:
       url: ldap://ldap.example.com.com/dc=example,dc=com?uid?sub?(objectClass=person)
       bindDN: cn=read-only-admin,dc=example,dc=com
       bindPassword:
         name: ldapbindpassword
       attributes:
         id: ["uid"]
         name: ["uid"]
         preferredUsername: ["uid"]
EOF


echo "waiting for authentication operator to become progressing"
oc wait clusteroperator authentication --for=condition=PROGRESSING

echo "waiting for authentication operator to become ready"
oc wait clusteroperator authentication --for=condition=Available
