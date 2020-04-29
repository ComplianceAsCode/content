#!/bin/bash

product=$1

# Build container in specified namespace. Else default to
# "openshift-compliance"
namespace=${2:-"openshift-compliance"}

root_dir=$(git rev-parse --show-toplevel)

pushd $root_dir

# build the product's content
"$root_dir/build_product" "$product"

if [ "$namespace" == "openshift-compliance" ]; then
    # Ensure openshift-compliance namespace exists. If it already exists, this
    # is not a problem.
    oc apply -f "$root_dir/ocp-resources/compliance-operator-ns.yaml"
fi

# Create buildconfig and ImageStream
# This enables us to create a configuration so we can build a container
# with the datastream
# If they already exist, this is not a problem
cat "$root_dir/ocp-resources/ds-build.yaml" | sed "s/\$PRODUCT/$product/" | \
    oc apply -n "$namespace" -f -

# Start build
oc start-build -n "$namespace" "openscap-$product-ds" \
    --from-file="$root_dir/build/ssg-$product-ds.xml"

# Wait some seconds until the object gets persisted
sleep 5

latest_build=$(oc get -n "$namespace" --no-headers buildconfigs "openscap-$product-ds" | awk '{print $4}')

popd

while true; do
    build_status=$(oc get builds -n "$namespace" --no-headers "openscap-$product-ds-$latest_build" | awk '{print $4}')

    if [ "$build_status" == "Complete" ]; then
        # Get built image
        image=$(oc get imagestreams -n "$namespace" --no-headers "openscap-$product-ds" | awk '{printf "%s:%s",$2, $3}')

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

