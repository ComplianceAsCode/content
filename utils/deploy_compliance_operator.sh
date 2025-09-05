#!/bin/bash

root_dir=$(git rev-parse --show-toplevel)

echo "* Ensuring openshift-compliance namespace exists."
# If it already exists, this is not a problem.
oc apply -f "$root_dir/ocp-resources/compliance-operator-ns.yaml"

# Some clusters may be slow... so let's wait til Kubernetes persists the new
# namespace
sleep 5

echo "* Creating CatalogSource"
# Create operator source so we can install the latest available release which
# is available from an "external datastore"; meaning, it's our upstream release
# which is not yet in OperatorHub
oc apply -f "$root_dir/ocp-resources/compliance-operator-catalog-source.yaml"

echo "* Creating OperatorGroup"
# Create operator group (defines which namespaces are targetted by the
# operator)
oc apply -f "$root_dir/ocp-resources/compliance-operator-operator-group.yaml"

echo "* Creating Subscription"
# Create subscription (which installs the operator)
oc apply -f "$root_dir/ocp-resources/compliance-operator-alpha-subscription.yaml"

echo "* The compliance-operator is now installing."
echo "* To take it into use, do:"
echo -e "\t$ oc project openshift-compliance"
