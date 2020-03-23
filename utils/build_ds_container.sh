#!/bin/bash

product=$1

root_dir=$(git rev-parse --show-toplevel)

pushd $root_dir

# build the product's content
"$root_dir/build_product" "$product"

# Ensure openshift-compliance namespace exists. If it already exists, this is
# not a problem.
oc create -f "$root_dir/ocp-resources/compliance-operator-ns.yaml" || true

# Create buildconfig and ImageStream
# This enables us to create a configuration so we can build a container
# with the datastream
# If they already exist, this is not a problem
cat "$root_dir/ocp-resources/ds-build.yaml" | sed "s/\$PRODUCT/$product/" | oc create -f - || true

# Start build
oc start-build -n openshift-compliance "openscap-$product-ds" --from-file="build/ssg-$product-ds.xml"

latest_build=$(oc get --no-headers buildconfigs "openscap-$product-ds" | awk '{print $4}')

popd

while true; do
    build_status=$(oc get builds --no-headers "openscap-$product-ds-$latest_build" | awk '{print $4}')

    if [ "$build_status" == "Complete" ]; then
        # Get built image
        image=$(oc get imagestreams --no-headers | awk '{printf "%s:%s",$2, $3}')

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

