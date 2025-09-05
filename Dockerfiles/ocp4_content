# This dockerfile builds the content in the current repo for OCP4

FROM registry.fedoraproject.org/fedora-minimal:latest as builder

WORKDIR /content

RUN microdnf -y install cmake make git /usr/bin/python3 python3-pyyaml python3-jinja2 openscap-utils

COPY . .

RUN ./build_product --datastream-only --debug ocp4 rhcos4 eks

FROM registry.access.redhat.com/ubi8/ubi-micro:latest
WORKDIR /
COPY --from=builder /content/build/ssg-ocp4-ds.xml .
COPY --from=builder /content/build/ssg-rhcos4-ds.xml .
COPY --from=builder /content/build/ssg-eks-ds.xml .
