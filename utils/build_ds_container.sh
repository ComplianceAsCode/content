#!/bin/bash

display_description() {
    echo "Build a content container image for OpenShift."
    echo ""
}

print_usage() {
    cmdname=$(basename $0)
    echo "Usage:"
    echo "    $cmdname -h                      Display this help message."
    echo "    $cmdname -n [namespace]          Build image in the given namespace (Defaults to 'openshift-compliance')."
    echo "    $cmdname -p                      Create ProfileBundle objects for the image."
    echo "    $cmdname -c                      Build content in-cluster (NOTE: This ignores the products and debug flags)."
    echo "    $cmdname -d                      Build content using the --debug flag."
    echo "    $cmdname -P [product] (-P ...)   Specify applicable product(s) to build. This option can be specified multiple times. (Defaults to 'ocp4' 'rhcos4')"
    exit 0
}

parms=(--datastream-only)

# Build container in specified namespace. Else default to
# "openshift-compliance"
namespace="openshift-compliance"
create_profile_bundles="false"
build_in_cluster="false"
products=()
default_products=(ocp4 rhcos4)

while getopts ":hdpcn:P:" opt; do
    case ${opt} in
        n ) # Set the namespace
            namespace=$OPTARG
            ;;
        d ) # Set debug build
            params+=(--debug)
            ;;
        p ) # Create ProfileBundle objects
            create_profile_bundles="true"
            ;;
        c ) # Build content in-cluster
            build_in_cluster="true"
            ;;
        h ) # Display help
            display_description
            print_usage
            ;;
        P ) # A product to build
            products+=($OPTARG)
            ;;
        \? ) 
            print_usage
            ;;
    esac
done

if [ ${#products[@]} -eq 0 ]; then
    products=${default_products[@]}
fi

echo "* Pushing datastream content image to namespace: $namespace"

root_dir=$(git rev-parse --show-toplevel)

pushd $root_dir

echo "* Building $(echo ${products[@]} | sed 's/ /, /g') products"

if [ "$namespace" == "openshift-compliance" ]; then
    # Ensure openshift-compliance namespace exists. If it already exists, this
    # is not a problem.
    oc apply -f "$root_dir/ocp-resources/compliance-operator-ns.yaml"
fi

if [ "$build_in_cluster" == "false" ];then
    # build the product's content
    "$root_dir/build_product" ${products[@]} "${params[@]}"
    result=$?

    if [ "$result" != "0" ]; then
        echo "Error building content"
        exit $result
    fi

    # Create buildconfig and ImageStream
    # This enables us to create a configuration so we can build a container
    # with the datastream
    # If they already exist, this is not a problem
    oc apply -n "$namespace" -f "$root_dir/ocp-resources/ds-from-local-build.yaml"

    # Create output directory
    from_dir=$(mktemp -d)

    # Copy datastream files to output directory
    cp "$root_dir/build/"*-ds.xml "$from_dir"
else
    # Create buildconfig and ImageStream
    # This enables us to create a configuration so we can build a container
    # with the datastream
    # If they already exist, this is not a problem
    oc apply -n "$namespace" -f "$root_dir/ocp-resources/ds-build-remote.yaml"

    # We'll copy the local contents for the build to happen remotely
    from_dir="."
fi

# Start build
oc start-build -n "$namespace" "openscap-ocp4-ds" --from-dir="$from_dir"

if [ "$build_in_cluster" == "false" ];then
    # Clean output directory
    rm -rf "$from_dir"
fi

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

        if [ "$create_profile_bundles" == "true" ]; then
            echo "Creating profile bundles"
            for prod in ${products[@]}
            do
                sed "s/\$PRODUCT/$prod/g" "$root_dir/ocp-resources/profile-bundle.yaml.tpl" | oc apply -n "$namespace" -f -
            done
        fi
        exit 0
    elif [ "$build_status" == "Error" ]; then
        echo "Error!"
        echo "******"
        echo "Check the logs"
        exit 1
    fi
    echo "Build status is still: $build_status"

    # Follow logs to express actual output
    if [ "$build_in_cluster" == "true" ];then
        oc logs -f "openscap-ocp4-ds-$latest_build-build"
    fi
done

