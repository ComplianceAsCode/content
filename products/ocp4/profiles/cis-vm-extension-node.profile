---
documentation_complete: true

title: 'CIS Red Hat Openshift Virtual Machine Extension Benchmark (Node)'

platform: ocp4-node

metadata:
    version: 1.0.0
    SMEs:
        - rhmdnd
        - Vincent056
        - yuumasato
        - abushkin-redhat
        - taimurhafeez

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Virtual Machine Extension Benchmark™, V1.0.0.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Virtual Machine Extension Benchmarks™ content.

    Note that this part of the profile is meant to run on the Operating System
    that Red Hat OpenShift Container Platform 4 runs on top of, covering the
    benchmark's node-level controls (host file permissions, kernel and CPU
    configuration). The platform-level controls are covered by the companion
    cis-vm-extension profile.

selections:
    - kubevirt-cache-directory-permissions
    - kubevirt-nested-virtualization-disabled
    - kubevirt-vcpu-metrics-enabled
    - kubevirt-seccomp-profile-permissions
    - kubevirt-cpu-vulnerabilities-mitigated
