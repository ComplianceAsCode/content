---
documentation_complete: true

title: 'CIS Red Hat OpenShift Container Platform 4 Benchmark'

platform: ocp4

metadata:
    SMEs:
        - rhmdnd
        - Vincent056
        - yuumasato
    version: 1.7.0

description: |-
    This profile defines a baseline that aligns to the Center for Internet Security®
    Red Hat OpenShift Container Platform 4 Benchmark™, V1.7.

    This profile includes Center for Internet Security®
    Red Hat OpenShift Container Platform 4 CIS Benchmarks™ content.

    Note that this part of the profile is meant to run on the Platform that
    Red Hat OpenShift Container Platform 4 runs on top of.

    This profile is applicable to OpenShift versions 4.12 and greater.

filter_rules: '"ocp4-node" not in platform and "ocp4-master-node" not in platform and "ocp4-node-on-sdn"
    not in platform and "ocp4-node-on-ovn" not in platform'

selections:
    - cis_ocp:all
    ### Variables
    - var_openshift_audit_profile=WriteRequestBodies
    ### Helper Rules
    ### This is a helper rule to fetch the required api resource for detecting OCP version
    - version_detect_in_ocp
    - version_detect_in_hypershift
