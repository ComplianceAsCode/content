# This is a template that is meant to create a profilebundle
# for a specified product
# Note that this is hardcoded to use the imagestream created by the
# build_ds_container.sh script in the utils directory.
apiVersion: compliance.openshift.io/v1alpha1
kind: ProfileBundle
metadata:
  name: upstream-$PRODUCT
spec:
  contentImage: openscap-ocp4-ds:latest
  contentFile: ssg-$PRODUCT-ds.xml
