#!/bin/bash

root_dir=$(git rev-parse --show-toplevel)

echo "Ensuring openshift-compliance namespace exists."
# If it already exists, this is not a problem.
oc create -f "$root_dir/ocp-resources/compliance-operator-ns.yaml" || true

echo "Creating OperatorSource"
# Create operator source so we can install the latest available release which
# is available from an "external datastore"; meaning, it's our upstream release
# which is not yet in OperatorHub
oc create -f "$root_dir/ocp-resources/compliance-operator-source.yaml"

echo "Creating CatalogSourceConfig"
# This allows us to create subscriptions
oc create -f "$root_dir/ocp-resources/compliance-operator-csc.yaml"

echo "Creating OperatorGroup"
# Create operator group (defines which namespaces are targetted by the
# operator)
oc create -f "$root_dir/ocp-resources/compliance-operator-operator-group.yaml"

echo "Creating Subscription"
# Create subscription (which installs the operator)
oc create -f "$root_dir/ocp-resources/compliance-operator-alpha-subscription.yaml"
