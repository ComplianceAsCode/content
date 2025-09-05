#!/bin/bash

# Build container in specified namespace. Else default to
# "openshift-compliance"
namespace=${1:-"openshift-compliance"}

echo "* Pushing datastream content image to namespace: $namespace"

root_dir=$(git rev-parse --show-toplevel)

pushd $root_dir

echo "* Building ocp4, rhel7, rhel8, rhcos4 products"
# build the product's content
"$root_dir/build_product" ocp4 rhel7 rhel8 rhcos4

if [ "$namespace" == "openshift-compliance" ]; then
    # Ensure openshift-compliance namespace exists. If it already exists, this
    # is not a problem.
    oc apply -f "$root_dir/ocp-resources/compliance-operator-ns.yaml"
fi

# Create buildconfig and ImageStream
# This enables us to create a configuration so we can build a container
# with the datastream
# If they already exist, this is not a problem
oc apply -n "$namespace" -f "$root_dir/ocp-resources/ds-build.yaml"

# Create output directory
ds_dir=$(mktemp -d)

# Copy datastream files to output directory
cp "$root_dir/build/"*-ds.xml "$ds_dir"

# Start build
oc start-build -n "$namespace" "openscap-ocp4-ds" --from-dir="$ds_dir"

# Clean output directory
rm -rf "$ds_dir"

# Wait some seconds until the object gets persisted
sleep 5

latest_build=$(oc get -n "$namespace" --no-headers buildconfigs "openscap-ocp4-ds" | awk '{print $4}')

popd

while true; do
    build_status=$(oc get builds -n "$namespace" --no-headers "openscap-ocp4-ds-$latest_build" | awk '{print $4}')

    if [ "$build_status" == "Complete" ]; then
        # Get built image
        image=$(oc get imagestreams -n "$namespace" --no-headers "openscap-ocp4-ds" | awk '{printf "%s:%s",$2, $3}')

        echo "Success!"
        echo "********"
        echo "Your image is available at: $image"
        exit 0
    elif [ "$build_status" == "Error" ]; then
        echo "Error!"
        echo "******"
        echo "Check the logs"
        exit 1
    fi
    echo "Retrying... build status is still: $build_status"
done

