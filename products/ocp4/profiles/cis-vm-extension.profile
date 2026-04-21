---
documentation_complete: true

metadata:
    version: 1.0.0
    SMEs:
        - rhmdnd
        - Vincent056
        - yuumasato

title: 'CIS Red Hat Openshift Virtual Machine Extension Benchmark'

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Virtual Machine Extension Benchmark™, V1.0.0.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Virtual Machine Extension Benchmarks™ content.

    Note that this part of the profile is meant to run on the Platform that
    Red Hat OpenShift Container Platform runs on top of.

scanner_type: CEL

selections:
    - kubevirt-nonroot-feature-gate-is-enabled
    - kubevirt-no-permitted-host-devices
    - kubevirt-persistent-reservation-disabled
    - kubevirt-no-vms-overcommitting-guest-memory
    - kubevirt-enforce-trusted-tls-registries
