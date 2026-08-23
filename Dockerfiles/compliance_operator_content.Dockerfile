# This dockerfile is used by the `utils/build_ds_container.sh` script in order
# to persist the built content into a remote container image repository.
FROM registry.access.redhat.com/ubi8/ubi-micro:latest
WORKDIR /
ADD ./build/* .
